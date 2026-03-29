#!/usr/bin/env bash
set -euo pipefail

# Patches YAML files in apps/ and infrastructure/ using configurable yq rules
# so workloads can schedule on a single CI node.
# Rules are defined in patch-manifests.yaml.

DRY_RUN="${DRY_RUN:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG="$SCRIPT_DIR/patch-manifests.yaml"

# Use compact sequence indentation (-c) to match yamllint indent-sequences: false
YQ_OPTS=(-I2 -c)

rule_count=$(yq '.rules | length' "$CONFIG")

# --- Optimization 1: Pre-read all config into bash arrays at startup ---
declare -a rule_expressions rule_error_tolerant rule_exclude_paths rule_exclude_names

for (( i=0; i<rule_count; i++ )); do
  rule_expressions[i]=$(yq ".rules[$i].expression" "$CONFIG")
  rule_error_tolerant[i]=$(yq ".rules[$i].error_tolerant // false" "$CONFIG")
  # Join exclude_paths with | delimiter
  rule_exclude_paths[i]=$(yq -r '.rules['"$i"'].exclude_paths // [] | .[]' "$CONFIG" | tr '\n' '|')
  # Join exclude_names with | delimiter
  rule_exclude_names[i]=$(yq -r '.rules['"$i"'].exclude_names // [] | .[]' "$CONFIG" | tr '\n' '|')
done

# --- Optimization 2: Embed exclude_names into the suspend expression ---
# Find the suspend rule (the one that selects HelmRelease) and bake in exclusions
for (( i=0; i<rule_count; i++ )); do
  if [[ "${rule_expressions[i]}" == *'select(.kind == "HelmRelease")'* && -n "${rule_exclude_names[i]}" ]]; then
    # Build yq conditions: .metadata.name != "name1" and .metadata.name != "name2" ...
    exclude_condition=""
    IFS='|' read -ra names <<< "${rule_exclude_names[i]}"
    for name in "${names[@]}"; do
      [[ -z "$name" ]] && continue
      if [[ -n "$exclude_condition" ]]; then
        exclude_condition+=" and "
      fi
      exclude_condition+=".metadata.name != \"$name\""
    done
    if [[ -n "$exclude_condition" ]]; then
      rule_expressions[i]="(select(.kind == \"HelmRelease\" and $exclude_condition) | .spec.suspend) = true"
      # Clear exclude_names since they're now embedded
      rule_exclude_names[i]=""
    fi
  fi
done

# --- Optimization 3: Pre-filter files with grep ---
# Build a grep pattern from keywords that the rules could match
# Rules target: affinity, topologySpreadConstraints, resources (cpu/memory), HelmRelease
grep_pattern='affinity|topologySpreadConstraints|resources:|kind: HelmRelease'
mapfile -t files < <(grep -rl -E "$grep_pattern" "$REPO_ROOT/apps" "$REPO_ROOT/infrastructure" \
  --include='*.yaml' --include='*.yml' 2>/dev/null || true)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No files matched pre-filter. Done."
  exit 0
fi

# --- Optimization 4: Process files in parallel using background jobs ---
# Temp dir for tracking patched files (atomic via touch)
patch_dir=$(mktemp -d)
trap 'rm -rf "$patch_dir"' EXIT

max_jobs=$(nproc)

process_file() {
  local file="$1"
  local rel_path="${file#"$REPO_ROOT/"}"

  # Capture comment-stripped snapshot to detect semantic changes only
  # (yq round-tripping reformats comments/blank lines, causing false positives)
  local before
  before=$(yq eval "${YQ_OPTS[@]}" '... comments=""' "$file" 2>/dev/null) || return 0

  # Process rules through a temp file to handle error_tolerant rules individually
  # Protect blank lines and block scalars from yq reformatting.
  # - Blank lines become marker comments (yq preserves comments through rules).
  # - Block scalar content (| or >) is replaced with a quoted placeholder so yq
  #   cannot reformat it; original content is saved to temp files and restored after.
  local tmpfile block_dir
  tmpfile=$(mktemp)
  block_dir=$(mktemp -d)
  awk -v bdir="$block_dir" '
    BEGIN { in_block = 0; n = 0 }
    {
      match($0, /^[[:space:]]*/); indent = RLENGTH
      if (in_block) {
        if (/^[[:space:]]*$/ || indent >= block_indent) {
          print >> bfile; next
        }
        in_block = 0
      }
      if (/: [|>][-+]?[0-9]*[[:space:]]*$/) {
        n++; in_block = 1; block_indent = indent + 1
        bfile = bdir "/b" n
        print > bfile
        sub(/: [|>][-+]?[0-9]*[[:space:]]*$/, ": \"__BLOCK_" n "__\"")
        print; next
      }
      if (/^[[:space:]]*$/) print "# __BLANK_LINE__"
      else print
    }
  ' "$file" > "$tmpfile"

  for (( i=0; i<rule_count; i++ )); do
    # Check if file matches any exclude_paths for this rule (bash string match)
    local skip=false
    if [[ -n "${rule_exclude_paths[i]}" ]]; then
      IFS='|' read -ra paths <<< "${rule_exclude_paths[i]}"
      for prefix in "${paths[@]}"; do
        [[ -z "$prefix" ]] && continue
        if [[ "$rel_path" == "$prefix"/* ]]; then
          skip=true
          break
        fi
      done
    fi

    # Check exclude_names if still needed (non-embedded rules)
    if [[ "$skip" == "false" && -n "${rule_exclude_names[i]}" ]]; then
      local resource_name
      resource_name=$(yq '.metadata.name // ""' "$tmpfile" 2>/dev/null) || resource_name=""
      if [[ -n "$resource_name" ]]; then
        IFS='|' read -ra names <<< "${rule_exclude_names[i]}"
        for excluded in "${names[@]}"; do
          [[ -z "$excluded" ]] && continue
          if [[ "$resource_name" == "$excluded" ]]; then
            skip=true
            break
          fi
        done
      fi
    fi

    [[ "$skip" == "true" ]] && continue

    if [[ "${rule_error_tolerant[i]}" == "true" ]]; then
      yq eval "${YQ_OPTS[@]}" "${rule_expressions[i]}" -i "$tmpfile" 2>/dev/null || true
    else
      yq eval "${YQ_OPTS[@]}" "${rule_expressions[i]}" -i "$tmpfile"
    fi
  done

  # Restore blank lines and block scalars
  sed -i 's/^[[:space:]]*# __BLANK_LINE__$//' "$tmpfile"
  for bfile in "$block_dir"/b*; do
    [[ -f "$bfile" ]] || continue
    local bn
    bn=$(basename "$bfile" | sed 's/^b//')
    local lnum
    lnum=$(grep -n "\"__BLOCK_${bn}__\"" "$tmpfile" | head -1 | cut -d: -f1) || true
    if [[ -n "$lnum" ]]; then
      sed -i -e "${lnum}r ${bfile}" -e "${lnum}d" "$tmpfile"
    fi
  done
  rm -rf "$block_dir"

  local after
  after=$(yq eval "${YQ_OPTS[@]}" '... comments=""' "$tmpfile")
  if [[ "$after" != "$before" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "Would patch: $rel_path"
      diff --color=auto -u "$file" "$tmpfile" || true
    else
      cp "$tmpfile" "$file"
      echo "Patched: $rel_path"
    fi
    touch "$patch_dir/$(echo "$file" | md5sum | cut -d' ' -f1)"
  fi
  rm -f "$tmpfile"
}

job_count=0
for file in "${files[@]}"; do
  process_file "$file" &
  job_count=$((job_count + 1))
  if (( job_count >= max_jobs )); then
    wait -n
    job_count=$((job_count - 1))
  fi
done
wait

patched=$(find "$patch_dir" -type f | wc -l)
if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry run complete. Would patch $patched file(s)."
else
  echo "Done. Patched $patched file(s)."
fi
