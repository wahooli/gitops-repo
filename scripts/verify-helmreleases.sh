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

  for file in $(cd "$REPO_ROOT/clusters/${CLUSTER_NAME}" && ls -dv1 * 2>/dev/null); do
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

while IFS='|' read -r name deps source ready; do
  [[ -z "$name" ]] && continue
  all_hr_names+=("$name")
  hr_deps[$name]="$deps"
  hr_source[$name]="$source"
  hr_ready[$name]="$ready"
done < <(kubectl "${CONTEXT_ARGS[@]}" get helmrelease -n "$HELMRELEASE_NAMESPACE" -o json 2>/dev/null \
  | jq -r '.items[] | [
      .metadata.name,
      ([.spec.dependsOn[]?.name] | join(" ")),
      (.spec.chart.spec.sourceRef.name // ""),
      ((.status.conditions // []) | map(select(.type == "Ready")) | .[0].status // "Unknown")
    ] | join("|")')

# --- Build processing set: targets + transitive unready deps ---
declare -A to_process=()

expand_deps() {
  local hr="$1"
  [[ -n "${to_process[$hr]:-}" ]] && return
  [[ -z "${hr_ready[$hr]:-}" ]] && return  # doesn't exist in cluster
  to_process[$hr]=1
  for dep in ${hr_deps[$hr]}; do
    [[ "${hr_ready[$dep]:-}" != "True" ]] && expand_deps "$dep"
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
  [[ "${hr_ready[$name]}" == "True" && -z "${to_process[$name]:-}" ]] && completed[$name]=1
done

ready_count=${#completed[@]}
process_count=${#to_process[@]}
echo "Already ready: $ready_count HelmReleases, to process: $process_count"

if [[ $process_count -eq 0 ]]; then
  echo "All target HelmReleases are ready."
  exit 0
fi

# --- Per-HelmRelease reconciliation (runs in subshell for parallel waves) ---
reconcile_helmrelease() {
  local hr="$1"

  # Resume if suspended
  flux resume helmrelease "$hr" -n "$HELMRELEASE_NAMESPACE" "${CONTEXT_ARGS[@]}" 2>/dev/null || true

  # Reconcile source if not ready
  local source="${hr_source[$hr]}"
  if [[ -n "$source" && "$source" != "null" ]]; then
    local source_ready
    source_ready=$(flux get source helm "$source" -n "$HELMRELEASE_NAMESPACE" --no-header "${CONTEXT_ARGS[@]}" 2>/dev/null | awk '{print tolower($4)}')
    if [[ "$source_ready" != "true" ]]; then
      echo "  Reconciling source: $source"
      flux reconcile source helm "$source" -n "$HELMRELEASE_NAMESPACE" "${CONTEXT_ARGS[@]}" 2>/dev/null || true
    fi
  fi

  # Reconcile chart if not ready
  local chart_name="${HELMRELEASE_NAMESPACE}-${hr}"
  local chart_ready
  chart_ready=$(flux get source chart "$chart_name" -n "$HELMRELEASE_NAMESPACE" --no-header "${CONTEXT_ARGS[@]}" 2>/dev/null | awk '{print tolower($4)}')
  if [[ "$chart_ready" != "true" ]]; then
    echo "  Reconciling chart: $chart_name"
    flux reconcile source chart "$chart_name" -n "$HELMRELEASE_NAMESPACE" "${CONTEXT_ARGS[@]}" 2>/dev/null || true
  fi

  # Check current ready status
  local ready_status
  ready_status=$(flux get helmrelease "$hr" -n "$HELMRELEASE_NAMESPACE" --no-header "${CONTEXT_ARGS[@]}" 2>/dev/null \
    | awk '{print tolower($4)}')

  if [[ "$ready_status" == "true" && "$RECONCILE_READY" != "true" ]]; then
    echo "  $hr: already ready"
  elif [[ "$ready_status" == "unknown" ]]; then
    echo "  $hr: status unknown, waiting..."
    kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" \
      wait helmrelease/"$hr" \
      --for=condition=ready \
      --timeout="${HELMRELEASE_TIMEOUT}" || return 1
    echo "  $hr: OK"
  else
    echo "  Reconciling $hr..."
    if ! flux reconcile helmrelease "$hr" \
      -n "$HELMRELEASE_NAMESPACE" \
      --timeout="${HELMRELEASE_TIMEOUT}" \
      "${CONTEXT_ARGS[@]}"; then
      # Reconcile command failed — check if the release is actually ready
      local post_ready
      post_ready=$(flux get helmrelease "$hr" -n "$HELMRELEASE_NAMESPACE" --no-header "${CONTEXT_ARGS[@]}" 2>/dev/null \
        | awk '{print tolower($4)}')
      if [[ "$post_ready" != "true" ]]; then
        echo "  Failed reconciling helmrelease: $hr" >&2
        return 1
      fi
      echo "  $hr: reconcile command failed but release is ready"
    fi

    kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" \
      wait helmrelease/"$hr" \
      --for=condition=ready \
      --timeout="${HELMRELEASE_TIMEOUT}" || return 1
    echo "  $hr: OK"
  fi
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
    $deps_met && wave+=("$hr")
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
    wave_pids=()

    for hr in "${wave[@]}"; do
      (
        group_start "HelmRelease $hr"
        reconcile_helmrelease "$hr"
        group_end
      ) > "$tmpdir/$hr.log" 2>&1 &
      wave_pids+=($!)
    done

    # Wait for all and collect results
    wave_failed=""
    for i in "${!wave_pids[@]}"; do
      if ! wait "${wave_pids[$i]}"; then
        [[ -z "$wave_failed" ]] && wave_failed="${wave[$i]}"
      fi
    done

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
echo "HelmRelease verification complete. ($process_count reconciled, $ready_count already ready)"

exit 0
