#!/bin/sh

apk add --no-cache curl jq > /dev/null 2>&1 || { echo "Failed to install dependencies"; exit 1; }

API="$${AUTHENTIK_URL}/api/v3"
AUTH="Authorization: Bearer $${AUTHENTIK_TOKEN}"
TAB=$(printf '\t')

parse_resp() {
  code=$(echo "$1" | tail -1)
  body=$(echo "$1" | sed '$d')
}

http_ok() { [ "$code" -ge 200 ] 2>/dev/null && [ "$code" -lt 300 ]; }

print_body() { echo "$body" | jq . 2>/dev/null || echo "$body"; }

blueprint_name() {
  sed -n '/^metadata:/,/^[^ ]/{s/^  name: *//p;}' "$1" | head -1
}

echo "Waiting for authentik to be ready..."
until curl -sf --connect-timeout 5 --max-time 10 "$${API}/root/config/" -H "$${AUTH}" > /dev/null 2>&1; do
  sleep 10
done
echo "Authentik is ready"

# Fetch all existing blueprints into a name->pk map
bp_map=$(mktemp)
page=1
while true; do
  resp=$(curl -sf --connect-timeout 5 --max-time 15 \
    "$${API}/managed/blueprints/?page=$page&page_size=100" \
    -H "$${AUTH}")
  [ -n "$resp" ] || break
  echo "$resp" | jq -r '.results[] | "\(.name)\t\(.pk)"' >> "$bp_map"
  next=$(echo "$resp" | jq -r '.pagination.next // empty')
  [ -n "$next" ] || break
  page=$((page + 1))
done
echo "Found $(wc -l < "$bp_map") existing blueprints"

find_pk() {
  awk -F'\t' -v name="$1" '$1 == name { print $2; exit }' "$bp_map"
}

errors=0
tmp=$(mktemp)
pk_list=$(mktemp)

# Phase 1: create or update all blueprints
echo ""
echo "--- Phase 1: create/update ---"
phase1_pending=$(mktemp)
for file in /blueprints/*.yaml; do
  [ -f "$file" ] || continue
  name=$(blueprint_name "$file")
  if [ -z "$name" ]; then
    echo "SKIP: $(basename "$file") — no metadata.name"
    continue
  fi
  echo "$file" >> "$phase1_pending"
done

phase1_attempt=1
max_phase1_attempts=3
while [ -s "$phase1_pending" ] && [ "$phase1_attempt" -le "$max_phase1_attempts" ]; do
  [ "$phase1_attempt" -gt 1 ] && echo "--- create/update retry $phase1_attempt ---"
  phase1_retry=$(mktemp)
  while IFS= read -r file; do
    name=$(blueprint_name "$file")
    pk=$(find_pk "$name")

    if [ -n "$pk" ]; then
      action="UPDATE"
      jq -n --rawfile content "$file" '{content: $content, enabled: true}' > "$tmp"
      url="$${API}/managed/blueprints/$${pk}/"
      method="PATCH"
    else
      action="CREATE"
      jq -n --rawfile content "$file" --arg name "$name" \
        '{name: $name, content: $content, enabled: true}' > "$tmp"
      url="$${API}/managed/blueprints/"
      method="POST"
    fi

    parse_resp "$(curl -sS -w '\n%{http_code}' --connect-timeout 5 --max-time 480 \
      -X "$method" "$url" \
      -H "$${AUTH}" -H "Content-Type: application/json" \
      --data-binary "@$tmp")"

    if http_ok; then
      [ -z "$pk" ] && pk=$(echo "$body" | jq -r '.pk // empty')
      printf '%s\t%s\t%s\n' "$pk" "$file" "$name" >> "$pk_list"
      echo "$${action}D: $name"
    elif [ "$code" -ge 500 ] 2>/dev/null; then
      echo "$${action} FAILED ($code): $name (will retry)"
      print_body
      echo "$file" >> "$phase1_retry"
    else
      echo "$${action} FAILED ($code): $name"
      print_body
      errors=$((errors + 1))
    fi
    sleep 1
  done < "$phase1_pending"
  rm -f "$phase1_pending"
  phase1_pending="$phase1_retry"
  if [ -s "$phase1_pending" ]; then
    echo "Retrying in 10s..."
    sleep 10
  fi
  phase1_attempt=$((phase1_attempt + 1))
done
if [ -s "$phase1_pending" ]; then
  echo "Failed to create/update after $max_phase1_attempts attempts:"
  while IFS= read -r file; do
    echo "  - $(blueprint_name "$file")"
    errors=$((errors + 1))
  done < "$phase1_pending"
fi
rm -f "$phase1_pending"

# Phase 2: apply sequentially (avoids DB deadlocks from parallel tasks)
echo ""
echo "--- Phase 2: apply ---"
max_wait="$${BLUEPRINT_APPLY_WAIT:-120}"
task_filter='.results[] | select(.actor_name == "authentik.blueprints.v1.tasks.apply_blueprint") | .aggregated_status | select(test("queued|consumed|running|preprocess|postprocess"))'
while IFS="$TAB" read -r pk file name; do
  parse_resp "$(curl -sS -w '\n%{http_code}' --connect-timeout 5 --max-time 120 \
    -X POST "$${API}/managed/blueprints/$${pk}/apply/" \
    -H "$${AUTH}" -H "Content-Type: application/json")"
  if http_ok; then
    echo "APPLIED: $name"
  else
    echo "APPLY FAILED ($code): $name"
    print_body
    errors=$((errors + 1))
    continue
  fi
  # Wait for apply task to complete before starting next
  wait_elapsed=0
  while [ "$wait_elapsed" -lt "$max_wait" ]; do
    sleep 3
    wait_elapsed=$((wait_elapsed + 3))
    active=$(curl -sf --connect-timeout 5 --max-time 10 \
      "$${API}/tasks/tasks/?page_size=100" \
      -H "$${AUTH}" | jq "[$${task_filter}] | length")
    if [ "$active" = "0" ] 2>/dev/null; then
      break
    fi
    echo "  waiting for $name ($active task(s) active)..."
  done
  [ "$wait_elapsed" -ge "$max_wait" ] && echo "WARNING: timed out waiting for $name"
done < "$pk_list"

# Phase 3: disable all (with retries + verification)
echo ""
echo "--- Phase 3: disable ---"
sleep 5
disable_pending="$pk_list"
disable_attempt=1
max_disable_attempts=5
while [ -s "$disable_pending" ] && [ "$disable_attempt" -le "$max_disable_attempts" ]; do
  [ "$disable_attempt" -gt 1 ] && echo "--- disable retry $disable_attempt ---"
  disable_retry=$(mktemp)
  while IFS="$TAB" read -r pk file name; do
    jq -n --rawfile content "$file" '{content: $content, enabled: false}' > "$tmp"
    parse_resp "$(curl -sS -w '\n%{http_code}' --connect-timeout 5 --max-time 30 \
      -X PATCH "$${API}/managed/blueprints/$${pk}/" \
      -H "$${AUTH}" -H "Content-Type: application/json" \
      --data-binary "@$tmp")"
    enabled=$(echo "$body" | jq -r 'if .enabled then "true" else "false" end')
    status=$(echo "$body" | jq -r '.status // "unknown"')
    if http_ok && [ "$enabled" = "false" ]; then
      echo "DISABLED: $name (status=$status)"
    else
      echo "DISABLE FAILED ($code, enabled=$enabled, status=$status): $name"
      printf '%s\t%s\t%s\n' "$pk" "$file" "$name" >> "$disable_retry"
    fi
  done < "$disable_pending"
  [ "$disable_pending" != "$pk_list" ] && rm -f "$disable_pending"
  disable_pending="$disable_retry"
  # Verify: re-check via GET in case async saves re-enabled them
  if [ ! -s "$disable_pending" ]; then
    sleep 5
    while IFS="$TAB" read -r pk file name; do
      enabled=$(curl -sf --connect-timeout 5 --max-time 10 \
        "$${API}/managed/blueprints/$${pk}/" \
        -H "$${AUTH}" | jq -r 'if .enabled then "true" else "false" end')
      if [ "$enabled" = "true" ]; then
        echo "VERIFY: $name was re-enabled, will retry"
        printf '%s\t%s\t%s\n' "$pk" "$file" "$name" >> "$disable_pending"
      fi
    done < "$pk_list"
  fi
  if [ -s "$disable_pending" ]; then
    echo "Retrying in 10s..."
    sleep 10
  fi
  disable_attempt=$((disable_attempt + 1))
done
if [ -s "$disable_pending" ]; then
  echo "Failed to disable after $max_disable_attempts attempts:"
  while IFS="$TAB" read -r pk file name; do
    echo "  - $name"
  done < "$disable_pending"
fi
[ "$disable_pending" != "$pk_list" ] && rm -f "$disable_pending"

rm -f "$bp_map" "$tmp" "$pk_list"

if [ "$errors" -gt 0 ]; then
  echo ""
  echo "DONE: $errors error(s)"
  sleep "$${BLUEPRINT_ERROR_SLEEP:-86400}"
  exit 1
fi

echo ""
echo "All blueprints applied successfully"
