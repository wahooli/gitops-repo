#!/usr/bin/env bash

set -euo pipefail

# Get script and repo root directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Argument parsing ---
# CI compatibility: accept TENANT env var or positional arg for cluster name
CLUSTER_NAME="${TENANT:-${1:-}}"
WORKLOAD_TIMEOUT="${WORKLOAD_TIMEOUT:-5m}"
HEALTHY=0
FAILED=0
FAILED_WORKLOADS=()

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
  echo "Usage: $0 <cluster-name>"
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

# --- Workload verification ---
verify_workload_type() {
  local type=$1
  local label=$2

  group_start "Verifying ${label}s"

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    local ns name ready_col desired

    case "$type" in
      deployment|statefulset)
        ns=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        ready_col=$(echo "$line" | awk '{print $3}')
        desired=$(echo "$ready_col" | cut -d/ -f2)
        ;;
      daemonset)
        ns=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        desired=$(echo "$line" | awk '{print $3}')
        ready_col="$(echo "$line" | awk '{print $5}')/${desired}"
        ;;
    esac

    # Skip workloads scaled to 0
    if [[ "$desired" == "0" ]]; then
      echo "  $ns/$name: scaled to 0, skipping"
      continue
    fi

    # Check if already fully ready
    local ready_count
    ready_count=$(echo "$ready_col" | cut -d/ -f1)
    if [[ "$ready_count" == "$desired" ]]; then
      echo "  $ns/$name: ${ready_col} ready"
      HEALTHY=$((HEALTHY + 1))
      continue
    fi

    # Not ready yet — wait for rollout
    echo "  $ns/$name: ${ready_col} ready — waiting..."
    if kubectl "${CONTEXT_ARGS[@]}" -n "$ns" rollout status "$type/$name" --timeout="$WORKLOAD_TIMEOUT" >/dev/null 2>&1; then
      echo "  $ns/$name: ready"
      HEALTHY=$((HEALTHY + 1))
    else
      echo "  $ns/$name: FAILED" >&2
      FAILED=$((FAILED + 1))
      FAILED_WORKLOADS+=("$ns/$name ($label)")
    fi

  done < <(kubectl "${CONTEXT_ARGS[@]}" get "$type" -A --no-headers 2>/dev/null)

  group_end
}

verify_workload_type "deployment" "Deployment"
verify_workload_type "statefulset" "StatefulSet"
verify_workload_type "daemonset" "DaemonSet"

echo ""
if [[ ${#FAILED_WORKLOADS[@]} -gt 0 ]]; then
  echo "Failed workloads:"
  for w in "${FAILED_WORKLOADS[@]}"; do
    echo "  - $w"
  done
  echo ""
fi

echo "Workload verification complete. ($HEALTHY healthy, $FAILED failed)"

if [[ "$FAILED" -gt 0 ]]; then
  exit 1
fi

exit 0
