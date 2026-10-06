#!/usr/bin/env bash

set -euo pipefail

# Get script and repo root directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Argument parsing ---
# CI compatibility: accept TENANT env var or positional arg for cluster name
CLUSTER_NAME="${TENANT:-${1:-}}"
HELM_RELEASES="${HELM_RELEASES:-${2:-}}"
HELMRELEASE_NAMESPACE="${HELMRELEASE_NAMESPACE:-flux-system}"
HELMRELEASE_TIMEOUT="${HELMRELEASE_TIMEOUT:-4m}"
RECONCILE_READY="${RECONCILE_READY:-true}"
HELMRELEASE_MAX_FAILURES="${HELMRELEASE_MAX_FAILURES:-3}"
FAIL_FAST_ERRORS='failed to create typed patch object|field not declared in schema|duplicate entries for key|execution error at|parse error|unable to build kubernetes objects|no matches for kind|no chart version found|invalid chart|chart pull error:.*: not found'

# Optional context override (Makefile sets CONTEXT=k3d-<cluster>; CI uses default)
CONTEXT_ARGS=()
if [[ -n "${CONTEXT:-}" ]]; then
  CONTEXT_ARGS=(--context "$CONTEXT")
fi

# GitHub Actions grouping
group_start() { [[ -n "${GITHUB_ACTIONS:-}" ]] && echo "::group::$1" || echo "--- $1 ---"; }
group_end() { [[ -n "${GITHUB_ACTIONS:-}" ]] && echo "::endgroup::" || true; }

# --- Validation ---
if [[ -z "$CLUSTER_NAME" ]]; then
  echo "Usage: $0 <cluster-name> [helmrelease1,helmrelease2,...]"
  echo ""
  echo "Available clusters:"
  for dir in "$REPO_ROOT"/clusters/*/; do
    [[ -d "$dir" ]] && echo "  $(basename "$dir")"
  done
  exit 1
fi

if [[ ! -d "$REPO_ROOT/clusters/$CLUSTER_NAME" ]]; then
  echo "Error: No cluster directory found at clusters/$CLUSTER_NAME"
  exit 1
fi

# --- HelmRelease discovery via flux build ---
if [[ -z "$HELM_RELEASES" ]]; then
  echo "Discovering HelmReleases for cluster: $CLUSTER_NAME"
  DISCOVERED=()

  for file in $(cd "$REPO_ROOT/clusters/${CLUSTER_NAME}" && ls -dv1 -- * 2>/dev/null); do
    kustomization_file="$REPO_ROOT/clusters/${CLUSTER_NAME}/${file}"
    [[ -f "$kustomization_file" ]] || continue

    kind=$(yq -r '.kind' "$kustomization_file")
    [[ "$kind" == "Kustomization" ]] || continue

    name=$(yq -r '.metadata.name' "$kustomization_file")
    namespace=$(yq -r '.metadata.namespace' "$kustomization_file")
    path=$(yq -r '.spec.path' "$kustomization_file" | sed 's|^\./||')

    releases=$(flux build kustomization "$name" \
      -n "$namespace" \
      --kustomization-file "$kustomization_file" \
      --path "$REPO_ROOT/$path" \
      --dry-run \
      "${CONTEXT_ARGS[@]}" 2>/dev/null \
      | yq -N 'select(.kind == "HelmRelease") | .metadata.name' 2>/dev/null || true)

    for release in $releases; do
      if [[ ! " ${DISCOVERED[*]:-} " =~ [[:space:]]${release}[[:space:]] ]]; then
        DISCOVERED+=("$release")
      fi
    done
  done

  if [[ ${#DISCOVERED[@]} -eq 0 ]]; then
    echo "No HelmReleases found in cluster $CLUSTER_NAME."
    exit 0
  fi

  HELM_RELEASES=$(IFS=","; echo "${DISCOVERED[*]}")
  echo "Found HelmReleases: $HELM_RELEASES"
fi

# --- Fetch all HelmRelease data from cluster ---
declare -A hr_deps=() hr_source=() hr_ready=()
all_hr_names=()

if ! hr_list_json=$(kubectl "${CONTEXT_ARGS[@]}" get helmreleases.helm.toolkit.fluxcd.io -n "$HELMRELEASE_NAMESPACE" -o json); then
  echo "Error: could not list HelmReleases in namespace $HELMRELEASE_NAMESPACE" >&2
  exit 1
fi

while IFS='|' read -r name deps source ready; do
  [[ -z "$name" ]] && continue
  all_hr_names+=("$name")
  hr_deps[$name]="$deps"
  hr_source[$name]="$source"
  hr_ready[$name]="$ready"
done < <(jq -r '.items[] | [
      .metadata.name,
      ([.spec.dependsOn[]?.name] | join(" ")),
      (.spec.chart.spec.sourceRef.name // ""),
      ((.status.conditions // []) | map(select(.type == "Ready")) | .[0].status // "Unknown")
    ] | join("|")' <<< "$hr_list_json")

# --- Build processing set: targets + transitive unready deps ---
declare -A to_process=()

expand_deps() {
  local hr="$1"
  [[ -n "${to_process[$hr]:-}" ]] && return
  [[ -z "${hr_ready[$hr]:-}" ]] && return  # doesn't exist in cluster
  to_process[$hr]=1
  for dep in ${hr_deps[$hr]}; do
    if [[ "${hr_ready[$dep]:-}" != "True" ]]; then
      expand_deps "$dep"
    fi
  done
}

IFS="," read -ra targets <<< "$HELM_RELEASES"
for hr in "${targets[@]}"; do
  if [[ -z "${hr_ready[$hr]:-}" ]]; then
    echo "  $hr: doesn't exist in cluster, skipping"
  elif [[ "$RECONCILE_READY" == "true" ]]; then
    to_process[$hr]=1
  elif [[ "${hr_ready[$hr]}" != "True" ]]; then
    expand_deps "$hr"
  fi
done

# Pre-mark ready HRs as completed (unless they're targets being re-reconciled)
declare -A completed=()
for name in "${all_hr_names[@]}"; do
  if [[ "${hr_ready[$name]}" == "True" && -z "${to_process[$name]:-}" ]]; then
    completed[$name]=1
  fi
done

# Count target HR states at start (independent of RECONCILE_READY)
ready_count=0
unready_count=0
for hr in "${targets[@]}"; do
  [[ -z "${hr_ready[$hr]:-}" ]] && continue
  if [[ "${hr_ready[$hr]}" == "True" ]]; then
    ((++ready_count))
  else
    ((++unready_count))
  fi
done

process_count=${#to_process[@]}
if [[ "$RECONCILE_READY" == "true" && $ready_count -gt 0 ]]; then
  echo "Targets: ${#targets[@]} (ready: $ready_count, unready: $unready_count). Reconciling all $process_count (RECONCILE_READY=true)."
else
  echo "Targets: ${#targets[@]} (ready: $ready_count, unready: $unready_count). Reconciling: $process_count."
fi

if [[ $process_count -eq 0 ]]; then
  echo "All target HelmReleases are ready."
  exit 0
fi

# --- Per-HelmRelease reconciliation (runs in subshell for parallel waves) ---

duration_seconds() {
  local d="$1" total=0 n unit
  while [[ "$d" =~ ^([0-9]+)([hms])(.*)$ ]]; do
    n="${BASH_REMATCH[1]}" unit="${BASH_REMATCH[2]}" d="${BASH_REMATCH[3]}"
    case "$unit" in h) total=$((total + n * 3600)) ;; m) total=$((total + n * 60)) ;; s) total=$((total + n)) ;; esac
  done
  [[ -z "$d" ]] || { echo "Invalid duration: $1" >&2; return 1; }
  echo "$total"
}

ready_status() {
  kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" get "$1" "$2" -o json 2>/dev/null \
    | jq -r 'if .kind == "HelmRepository" and .spec.type == "oci" then "True"
             else (((.status.conditions // []) | map(select(.type == "Ready")) | .[0].status) // "Unknown") end' \
    || echo "Unknown"
}

wait_helmrelease() {
  local hr="$1" token="$2" budget="$3"
  local deadline=$((SECONDS + budget)) start_failures="" sep=$'\x1f'
  local handled gen observed ready reason stalled failures message
  while true; do
    if IFS="$sep" read -r handled gen observed ready reason stalled failures message < <(
      kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" get helmreleases.helm.toolkit.fluxcd.io "$hr" -o json 2>/dev/null | jq -r --arg sep "$sep" '
        def cond(t): (.status.conditions // []) | map(select(.type == t)) | .[0];
        [ (.status.lastHandledReconcileAt // ""), (.metadata.generation | tostring),
          ((.status.observedGeneration // -1) | tostring), (cond("Ready").status // "Unknown"),
          (cond("Ready").reason // ""), (cond("Stalled").status // "False"),
          (((.status.installFailures // 0) + (.status.upgradeFailures // 0)) | tostring),
          ((cond("Ready").message // "") | gsub("[\n\t]"; " ")) ] | join($sep)'); then
      [[ -z "$start_failures" ]] && start_failures="$failures"
      if [[ ( -z "$token" || "$handled" == "$token" ) && "$ready" == "True" && "$observed" == "$gen" ]]; then
        return 0
      fi
      if [[ "$stalled" == "True" ]]; then
        echo "  $hr: stalled ($reason): $message" >&2
        return 1
      fi
      if [[ "$ready" == "False" ]] && grep -qE "$FAIL_FAST_ERRORS" <<< "$message"; then
        echo "  $hr: failed with an error retrying won't fix ($reason): $message" >&2
        return 1
      fi
      if (( failures - start_failures >= HELMRELEASE_MAX_FAILURES )); then
        echo "  $hr: failed $((failures - start_failures)) times since verification started ($reason): $message" >&2
        return 1
      fi
    fi
    if (( SECONDS >= deadline )); then
      echo "  $hr: not ready after ${budget}s (${reason:-no status}): ${message:-}" >&2
      return 1
    fi
    sleep 5
  done
}

reconcile_helmrelease() {
  local hr="$1"
  local budget
  budget=$(( $(duration_seconds "$HELMRELEASE_TIMEOUT") * 2 ))

  # Resume if suspended
  if [[ "$(kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" get helmreleases.helm.toolkit.fluxcd.io "$hr" \
      -o jsonpath='{.spec.suspend}' 2>/dev/null)" == "true" ]]; then
    echo "  Resuming $hr"
    kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" patch helmreleases.helm.toolkit.fluxcd.io "$hr" \
      --type=merge -p '{"spec":{"suspend":false}}' >/dev/null
  fi

  # Reconcile source if not ready
  local source="${hr_source[$hr]}"
  if [[ -n "$source" && "$source" != "null" && "$(ready_status helmrepositories.source.toolkit.fluxcd.io "$source")" != "True" ]]; then
    echo "  Reconciling source: $source"
    kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" annotate --overwrite helmrepositories.source.toolkit.fluxcd.io "$source" \
      "reconcile.fluxcd.io/requestedAt=$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)" >/dev/null 2>&1 || true
  fi

  # Reconcile chart if not ready
  local chart_name="${HELMRELEASE_NAMESPACE}-${hr}"
  if [[ "$(ready_status helmcharts.source.toolkit.fluxcd.io "$chart_name")" != "True" ]]; then
    echo "  Reconciling chart: $chart_name"
    kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" annotate --overwrite helmcharts.source.toolkit.fluxcd.io "$chart_name" \
      "reconcile.fluxcd.io/requestedAt=$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)" >/dev/null 2>&1 || true
  fi

  # Check current ready status
  local status
  status=$(ready_status helmreleases.helm.toolkit.fluxcd.io "$hr")

  if [[ "$status" == "True" && "$RECONCILE_READY" != "true" ]]; then
    echo "  $hr: already ready"
    return 0
  fi

  local token=""
  if [[ "$status" == "Unknown" ]]; then
    echo "  $hr: status unknown, waiting..."
  else
    echo "  Reconciling $hr..."
    token="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
    kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" annotate --overwrite \
      helmreleases.helm.toolkit.fluxcd.io/"$hr" "reconcile.fluxcd.io/requestedAt=$token" >/dev/null
  fi

  if ! wait_helmrelease "$hr" "$token" "$budget"; then
    echo "  Failed reconciling helmrelease: $hr" >&2
    return 1
  fi
  echo "  $hr: OK"
}

# --- Process in dependency waves ---
processed=0

while [[ $processed -lt $process_count ]]; do
  wave=()
  for hr in "${!to_process[@]}"; do
    [[ -n "${completed[$hr]:-}" ]] && continue
    deps_met=true
    for dep in ${hr_deps[$hr]}; do
      # Dep is met if: completed, or not in cluster (external/missing)
      [[ -n "${completed[$dep]:-}" || -z "${hr_ready[$dep]:-}" ]] && continue
      deps_met=false
      break
    done
    if $deps_met; then
      wave+=("$hr")
    fi
  done

  if [[ ${#wave[@]} -eq 0 ]]; then
    echo "Error: circular dependencies among remaining HelmReleases"
    exit 1
  fi

  # Sort wave for deterministic output
  mapfile -t wave < <(printf '%s\n' "${wave[@]}" | sort)

  echo ""
  echo "Wave [${wave[*]}] (${#wave[@]} HelmReleases)"

  if [[ ${#wave[@]} -eq 1 ]]; then
    # Single HR — run directly
    hr="${wave[0]}"
    group_start "HelmRelease $hr"
    if ! reconcile_helmrelease "$hr"; then
      group_end
      [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "failing_helmrelease=$hr" >> "$GITHUB_OUTPUT"
      exit 1
    fi
    group_end
    completed[$hr]=1
    ((++processed))
  else
    # Parallel reconciliation with captured output
    tmpdir=$(mktemp -d)
    declare -A wave_pid_hr=()

    for hr in "${wave[@]}"; do
      (
        group_start "HelmRelease $hr"
        reconcile_helmrelease "$hr"
        group_end
      ) > "$tmpdir/$hr.log" 2>&1 &
      wave_pid_hr[$!]="$hr"
    done

    # Wait for all and collect results
    wave_failed=""
    while [[ ${#wave_pid_hr[@]} -gt 0 ]]; do
      done_pid=""
      if wait -n -p done_pid "${!wave_pid_hr[@]}"; then rc=0; else rc=$?; fi
      [[ -z "$done_pid" ]] && break
      if [[ $rc -ne 0 && -z "$wave_failed" ]]; then
        wave_failed="${wave_pid_hr[$done_pid]}"
        for pid in "${!wave_pid_hr[@]}"; do
          if [[ "$pid" != "$done_pid" ]]; then
            kill "$pid" 2>/dev/null || true
            echo "  ${wave_pid_hr[$pid]}: aborted, $wave_failed failed" >> "$tmpdir/${wave_pid_hr[$pid]}.log"
          fi
        done
      fi
      unset "wave_pid_hr[$done_pid]"
    done
    unset wave_pid_hr

    # Print captured output sequentially
    for hr in "${wave[@]}"; do
      cat "$tmpdir/$hr.log"
      completed[$hr]=1
      ((++processed))
    done

    rm -rf "$tmpdir"

    if [[ -n "$wave_failed" ]]; then
      [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "failing_helmrelease=$wave_failed" >> "$GITHUB_OUTPUT"
      exit 1
    fi
  fi
done

echo ""
if [[ "$RECONCILE_READY" == "true" && $ready_count -gt 0 ]]; then
  echo "HelmRelease verification complete. ($process_count reconciled; $ready_count of those were already ready, $unready_count needed work)"
else
  echo "HelmRelease verification complete. ($process_count reconciled, $ready_count already ready)"
fi

exit 0
