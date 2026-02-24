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
RECONCILED=()
RECONCILED_SOURCES=()
RECONCILED_CHARTS=()
OCI_SOURCES=()
ORIG_IFS=$IFS

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
      # Deduplicate
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

# --- Reconciliation ---
fail() {
  local helmrelease=$1
  local message=${2:-}
  if [[ -n "$message" ]]; then
    echo "$message" >&2
  fi
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "failing_helmrelease=$helmrelease" >> "$GITHUB_OUTPUT"
  fi
  exit 1
}

reconcile() {
  local helmrelease=$1

  # Check helmrelease exists in cluster
  local check_exists
  check_exists=$(flux get helmrelease "$helmrelease" -n "$HELMRELEASE_NAMESPACE" "${CONTEXT_ARGS[@]}" 2>/dev/null || true)

  if [[ -n "$check_exists" ]]; then
    # Resolve dependencies
    local dependencies
    dependencies=$(kubectl "${CONTEXT_ARGS[@]}" get -n "$HELMRELEASE_NAMESPACE" helmrelease/"$helmrelease" -o yaml \
      | yq -e -r '[ .spec.dependsOn[].name ] | join(",")' 2>/dev/null || true)

    if [[ -n "$dependencies" ]]; then
      echo "  Resolving dependencies: $dependencies"
      IFS=","
      for dependency in $dependencies; do
        reconcile "$dependency"
      done
      # Ensure all dependencies are currently ready before proceeding
      IFS=","
      for dependency in $dependencies; do
        kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" \
          wait helmrelease/"$dependency" \
          --for=condition=ready \
          --timeout="${HELMRELEASE_TIMEOUT}" >/dev/null 2>&1 || true
      done
    fi

    IFS=$ORIG_IFS
    if [[ " ${RECONCILED[*]:-} " =~ [[:space:]]${helmrelease}[[:space:]] ]]; then
      echo "  $helmrelease: previously reconciled, skipping"
    else
      IFS=","

      # Get helmrelease details for source/chart reconciliation
      local hr_yaml
      hr_yaml=$(kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" get helmrelease/"$helmrelease" -o yaml 2>/dev/null)

      # Reconcile HelmRepository source if not already done
      local source_name
      source_name=$(echo "$hr_yaml" | yq -r '.spec.chart.spec.sourceRef.name' 2>/dev/null || true)
      if [[ -n "$source_name" && "$source_name" != "null" ]] && \
         [[ ! " ${RECONCILED_SOURCES[*]:-} " =~ [[:space:]]${source_name}[[:space:]] ]]; then
        echo "  Reconciling source: $source_name"
        local source_output
        source_output=$(flux reconcile source helm "$source_name" -n "$HELMRELEASE_NAMESPACE" "${CONTEXT_ARGS[@]}" 2>&1) || true
        RECONCILED_SOURCES+=("$source_name")
        if [[ "$source_output" == *"not supported"* ]]; then
          OCI_SOURCES+=("$source_name")
        fi
      fi

      # Reconcile HelmChart if not already done, or always if source is OCI
      local chart_name="${HELMRELEASE_NAMESPACE}-${helmrelease}"
      local oci_source=0
      [[ " ${OCI_SOURCES[*]:-} " =~ [[:space:]]${source_name}[[:space:]] ]] && oci_source=1

      if [[ ! " ${RECONCILED_CHARTS[*]:-} " =~ [[:space:]]${chart_name}[[:space:]] ]] || [[ "$oci_source" -eq 1 ]]; then
        local chart_ready
        chart_ready=$(flux get source chart "$chart_name" -n "$HELMRELEASE_NAMESPACE" --no-header "${CONTEXT_ARGS[@]}" 2>/dev/null | awk '{print tolower($4)}')
        if [[ "$chart_ready" != "true" || "$oci_source" -eq 1 ]]; then
          echo "  Reconciling chart: $chart_name"
          flux reconcile source chart "$chart_name" -n "$HELMRELEASE_NAMESPACE" "${CONTEXT_ARGS[@]}"
        fi
        RECONCILED_CHARTS+=("$chart_name")
      fi

      # Check if already ready (may have become ready since script start)
      local ready_status
      ready_status=$(flux get helmrelease "$helmrelease" -n "$HELMRELEASE_NAMESPACE" --no-header "${CONTEXT_ARGS[@]}" 2>/dev/null | awk '{print tolower($4)}')
      if [[ "$ready_status" == "true" ]]; then
        RECONCILED+=("$helmrelease")
        echo "  $helmrelease: already ready, skipping"
      elif [[ "$ready_status" == "unknown" ]]; then
        echo "  $helmrelease: status unknown, waiting for ready condition..."
        kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" \
          wait helmrelease/"$helmrelease" \
          --for=condition=ready \
          --timeout="${HELMRELEASE_TIMEOUT}" \
          || fail "$helmrelease" "Failed ready condition for helmrelease: $helmrelease"
        RECONCILED+=("$helmrelease")
        echo "  $helmrelease: OK"
      else
        echo "  Reconciling $helmrelease..."
        if ! flux reconcile helmrelease "$helmrelease" \
          -n "$HELMRELEASE_NAMESPACE" \
          --timeout="${HELMRELEASE_TIMEOUT}" \
          "${CONTEXT_ARGS[@]}"; then
          # Reconcile command failed — check if the release is actually ready
          local post_ready
          post_ready=$(flux get helmrelease "$helmrelease" -n "$HELMRELEASE_NAMESPACE" --no-header "${CONTEXT_ARGS[@]}" 2>/dev/null | awk '{print tolower($4)}')
          if [[ "$post_ready" != "true" ]]; then
            fail "$helmrelease" "Failed reconciling helmrelease: $helmrelease"
          fi
          echo "  $helmrelease: reconcile command failed but release is ready"
        fi

        kubectl "${CONTEXT_ARGS[@]}" -n "$HELMRELEASE_NAMESPACE" \
          wait helmrelease/"$helmrelease" \
          --for=condition=ready \
          --timeout="${HELMRELEASE_TIMEOUT}" \
          || fail "$helmrelease" "Failed ready condition for helmrelease: $helmrelease"

        RECONCILED+=("$helmrelease")
        echo "  $helmrelease: OK"
      fi
    fi
    IFS=","
  else
    echo "  $helmrelease: doesn't exist in cluster, skipping"
  fi
}

# Prepopulate RECONCILED with already-ready HelmReleases
while IFS= read -r ready_release; do
  [[ -n "$ready_release" ]] && RECONCILED+=("$ready_release")
done < <(flux get helmrelease -n "$HELMRELEASE_NAMESPACE" --no-header "${CONTEXT_ARGS[@]}" 2>/dev/null \
  | awk 'tolower($4) == "true" { print $1 }')

# Prepopulate RECONCILED_CHARTS with already-ready HelmCharts
while IFS= read -r ready_chart; do
  [[ -n "$ready_chart" ]] && RECONCILED_CHARTS+=("$ready_chart")
done < <(flux get source chart -n "$HELMRELEASE_NAMESPACE" --no-header "${CONTEXT_ARGS[@]}" 2>/dev/null \
  | awk 'tolower($4) == "true" { print $1 }')

if [[ ${#RECONCILED[@]} -gt 0 ]]; then
  echo "Already reconciled: ${#RECONCILED[@]} HelmReleases, ${#RECONCILED_CHARTS[@]} HelmCharts"
fi

IFS=","
for helmrelease in $HELM_RELEASES; do
  group_start "HelmRelease $helmrelease"
  reconcile "$helmrelease"
  group_end
done
IFS=$ORIG_IFS

echo ""
echo "HelmRelease verification complete. (${#RECONCILED[@]} reconciled)"

exit 0
