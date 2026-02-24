#!/usr/bin/env bash

set -euo pipefail

# Get script and repo root directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Argument parsing ---
# CI compatibility: accept TENANT env var or positional arg
CLUSTER_NAME="${TENANT:-${1:-}}"
KUSTOMIZATIONS="${KUSTOMIZATIONS:-${2:-}}"
KUSTOMIZATION_TIMEOUT="${KUSTOMIZATION_TIMEOUT:-5m}"

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
  echo "Usage: $0 <cluster-name> [kustomization1,kustomization2,...]"
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

is_kustomization_ready() {
  local name="$1"
  local namespace="$2"
  local status
  status=$(kubectl "${CONTEXT_ARGS[@]}" -n "$namespace" get kustomization "$name" \
    -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
  [[ "$status" == "True" ]]
}

verify_kustomization() {
  local kustomization_file="$1"
  local strict="${2:-}"

  if [[ ! -f "$kustomization_file" ]]; then
    echo "$kustomization_file doesn't exist!"
    exit 1
  fi

  local kustomization namespace
  kustomization=$(yq -r 'select(.kind == "Kustomization") | .metadata.name' "$kustomization_file")

  if [[ -z "$kustomization" ]] && [[ "$strict" == "true" ]]; then
    echo "$kustomization_file is not Kustomization kind!"
    exit 1
  elif [[ -n "$kustomization" ]]; then
    namespace=$(yq -r '.metadata.namespace' "$kustomization_file")

    group_start "Kustomization $kustomization"

    echo "kustomization file path: $kustomization_file"

    echo -n "flux build kustomization $kustomization"
    flux build kustomization "$kustomization" \
      -n "$namespace" \
      --kustomization-file "$kustomization_file" \
      --path "$REPO_ROOT/$(yq -r '.spec.path' "$kustomization_file" | sed 's|^\./||')" \
      "${CONTEXT_ARGS[@]}" > /dev/null && echo ": success!" || (echo ": failure!" && exit 1)

    if is_kustomization_ready "$kustomization" "$namespace"; then
      echo "kustomization $kustomization is already ready, skipping reconcile"
    else
      echo "flux reconcile"
      flux reconcile kustomization "$kustomization" \
        -n "$namespace" \
        --timeout="${KUSTOMIZATION_TIMEOUT}" \
        "${CONTEXT_ARGS[@]}" || exit 1

      echo "kubectl wait"
      kubectl "${CONTEXT_ARGS[@]}" -n "$namespace" \
        wait kustomization/"$kustomization" \
        --for=condition=ready \
        --timeout="${KUSTOMIZATION_TIMEOUT}" || exit 1
    fi

    group_end
  fi
}

# Reconcile flux-system first to ensure child Kustomization CRs exist
group_start "Kustomization flux-system"
echo "flux reconcile"
flux reconcile kustomization flux-system \
  -n flux-system \
  --timeout="${KUSTOMIZATION_TIMEOUT}" \
  "${CONTEXT_ARGS[@]}" --with-source || exit 1

echo "kubectl wait"
kubectl "${CONTEXT_ARGS[@]}" -n flux-system \
  wait kustomization/flux-system \
  --for=condition=ready \
  --timeout="${KUSTOMIZATION_TIMEOUT}" || exit 1
group_end

# Reconcile local-bootstrap if it exists (local k3d clusters only)
if flux get kustomization local-bootstrap -n flux-system "${CONTEXT_ARGS[@]}" >/dev/null 2>&1; then
  group_start "Kustomization local-bootstrap"
  echo "flux reconcile"
  flux reconcile kustomization local-bootstrap \
    -n flux-system \
    --timeout="${KUSTOMIZATION_TIMEOUT}" \
    "${CONTEXT_ARGS[@]}" || exit 1

  echo "kubectl wait"
  kubectl "${CONTEXT_ARGS[@]}" -n flux-system \
    wait kustomization/local-bootstrap \
    --for=condition=ready \
    --timeout="${KUSTOMIZATION_TIMEOUT}" || exit 1
  group_end
fi

if [[ -z "$KUSTOMIZATIONS" ]]; then
  echo "Iterating files in clusters/${CLUSTER_NAME}"
  for file in $(cd "$REPO_ROOT/clusters/${CLUSTER_NAME}" && ls -dv1 * 2>/dev/null); do
    kustomization_file="$REPO_ROOT/clusters/${CLUSTER_NAME}/${file}"
    [[ -f "$kustomization_file" ]] && verify_kustomization "$kustomization_file"
  done
else
  IFS=","
  for kustomization in $KUSTOMIZATIONS; do
    kustomization_file="$REPO_ROOT/clusters/${CLUSTER_NAME}/${kustomization}.yaml"
    verify_kustomization "$kustomization_file" "true"
  done
fi

# Wait for CoreDNS rollout (kube-dns kustomization may redeploy it)
echo "Waiting for CoreDNS rollout..."
kubectl "${CONTEXT_ARGS[@]}" -n kube-system rollout status deployment/coredns --timeout="${KUSTOMIZATION_TIMEOUT}"

exit 0
