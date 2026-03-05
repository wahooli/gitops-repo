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

build_kustomization() {
  local name="$1"
  local file="$2"
  local namespace="$3"

  echo -n "flux build kustomization $name"
  flux build kustomization "$name" \
    -n "$namespace" \
    --kustomization-file "$file" \
    --path "$REPO_ROOT/$(yq -r '.spec.path' "$file" | sed 's|^\./||')" \
    "${CONTEXT_ARGS[@]}" > /dev/null && echo ": success!" || { echo ": failure!"; return 1; }
}

reconcile_kustomization() {
  local name="$1"
  local namespace="$2"
  local file="$3"

  group_start "Kustomization $name"
  echo "kustomization file path: $file"

  if [[ "$RECONCILE_READY" != "true" ]] && is_kustomization_ready "$name" "$namespace"; then
    echo "kustomization $name is already ready, skipping reconcile"
  else
    echo "flux reconcile"
    flux reconcile kustomization "$name" \
      -n "$namespace" \
      --timeout="${KUSTOMIZATION_TIMEOUT}" \
      "${CONTEXT_ARGS[@]}" || return 1

    echo "kubectl wait"
    kubectl "${CONTEXT_ARGS[@]}" -n "$namespace" \
      wait kustomization/"$name" \
      --for=condition=ready \
      --timeout="${KUSTOMIZATION_TIMEOUT}" || return 1
  fi

  group_end
}

# --- Bootstrap: reconcile flux-system and local-bootstrap first ---

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

# --- Explicit kustomization list: sequential ---

if [[ -n "$KUSTOMIZATIONS" ]]; then
  IFS=","
  for kustomization in $KUSTOMIZATIONS; do
    kustomization_file="$REPO_ROOT/clusters/${CLUSTER_NAME}/${kustomization}.yaml"
    if [[ ! -f "$kustomization_file" ]]; then
      echo "$kustomization_file doesn't exist!"
      exit 1
    fi
    name=$(yq -r 'select(.kind == "Kustomization") | .metadata.name' "$kustomization_file")
    if [[ -z "$name" ]]; then
      echo "$kustomization_file is not Kustomization kind!"
      exit 1
    fi
    namespace=$(yq -r '.metadata.namespace' "$kustomization_file")
    build_kustomization "$name" "$kustomization_file" "$namespace" || exit 1
    reconcile_kustomization "$name" "$namespace" "$kustomization_file" || exit 1
  done
  unset IFS
else

  # --- Auto-discovery: parallel waves based on dependency graph ---

  echo "Iterating files in clusters/${CLUSTER_NAME}"

  declare -A ks_file ks_ns ks_deps
  all_ks=()

  for file in $(cd "$REPO_ROOT/clusters/${CLUSTER_NAME}" && ls -dv1 * 2>/dev/null); do
    kustomization_file="$REPO_ROOT/clusters/${CLUSTER_NAME}/${file}"
    [[ -f "$kustomization_file" ]] || continue

    name=$(yq -r 'select(.kind == "Kustomization") | .metadata.name' "$kustomization_file" 2>/dev/null)
    [[ -z "$name" ]] && continue

    ks_file[$name]="$kustomization_file"
    ks_ns[$name]=$(yq -r '.metadata.namespace' "$kustomization_file" 2>/dev/null)
    ks_deps[$name]=$(yq -r 'select(.kind == "Kustomization") | [.spec.dependsOn[]?.name] | join(" ")' "$kustomization_file" 2>/dev/null)
    all_ks+=("$name")
  done

  # Process kustomizations in dependency waves
  declare -A completed=()

  while [[ ${#completed[@]} -lt ${#all_ks[@]} ]]; do
    wave=()
    for ks in "${all_ks[@]}"; do
      [[ -n "${completed[$ks]:-}" ]] && continue
      # Check if all dependencies are completed (or external to the graph)
      deps_met=true
      for dep in ${ks_deps[$ks]}; do
        if [[ -n "${ks_file[$dep]:-}" && -z "${completed[$dep]:-}" ]]; then
          deps_met=false
          break
        fi
      done
      $deps_met && wave+=("$ks")
    done

    if [[ ${#wave[@]} -eq 0 ]]; then
      echo "Error: circular dependency detected among remaining kustomizations"
      exit 1
    fi

    echo ""
    echo "Wave [${wave[*]}]"

    # Validate all kustomizations in the wave (sequential, fast)
    for ks in "${wave[@]}"; do
      build_kustomization "$ks" "${ks_file[$ks]}" "${ks_ns[$ks]}" || exit 1
    done

    if [[ ${#wave[@]} -eq 1 ]]; then
      # Single kustomization — run directly, no need for background jobs
      reconcile_kustomization "${wave[0]}" "${ks_ns[${wave[0]}]}" "${ks_file[${wave[0]}]}" || exit 1
      completed[${wave[0]}]=1
    else
      # Parallel reconciliation with captured output
      tmpdir=$(mktemp -d)
      wave_pids=()

      for ks in "${wave[@]}"; do
        ( reconcile_kustomization "$ks" "${ks_ns[$ks]}" "${ks_file[$ks]}" ) \
          > "$tmpdir/$ks.log" 2>&1 &
        wave_pids+=($!)
      done

      wave_failed=0
      failed_ks=""
      for i in "${!wave_pids[@]}"; do
        if ! wait "${wave_pids[$i]}"; then
          wave_failed=1
          failed_ks="${failed_ks} ${wave[$i]}"
        fi
      done

      # Print captured output sequentially
      for ks in "${wave[@]}"; do
        cat "$tmpdir/$ks.log"
        completed[$ks]=1
      done

      rm -rf "$tmpdir"

      if [[ $wave_failed -ne 0 ]]; then
        echo "Failed kustomizations:${failed_ks}"
        exit 1
      fi
    fi
  done
fi

# Wait for CoreDNS rollout (kube-dns kustomization may redeploy it)
echo "Waiting for CoreDNS rollout..."
kubectl "${CONTEXT_ARGS[@]}" -n kube-system rollout status deployment/coredns --timeout="${KUSTOMIZATION_TIMEOUT}"

# In CI, suspend all kustomizations to prevent the kustomization controller from
# re-applying suspend: true to HelmReleases during helmrelease verification
if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
  echo "Suspending all kustomizations..."
  flux suspend kustomization --all -n flux-system "${CONTEXT_ARGS[@]}"
fi

exit 0
