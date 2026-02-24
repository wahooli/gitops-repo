#!/usr/bin/env bash

set -euo pipefail

# Get script and repo root directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Argument parsing & validation ---
CLUSTER_NAME="${1:-}"
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

CONTEXT_NAME="k3d-${CLUSTER_NAME}"

# Generate clustermesh CA certificate (shared across all clusters)
CLUSTERMESH_CA_DIR="$REPO_ROOT/local-clusters/.clustermesh-ca"
if [[ ! -f "$CLUSTERMESH_CA_DIR/tls.crt" || ! -f "$CLUSTERMESH_CA_DIR/tls.key" ]]; then
  echo "Generating clustermesh CA certificate..."
  mkdir -p "$CLUSTERMESH_CA_DIR"
  openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
    -keyout "$CLUSTERMESH_CA_DIR/tls.key" \
    -out "$CLUSTERMESH_CA_DIR/tls.crt" \
    -days 3650 -nodes \
    -subj "/CN=clustermesh-ca"
else
  echo "Using existing clustermesh CA from local-clusters/.clustermesh-ca/"
fi

# Push manifests to OCI registry
"$SCRIPT_DIR/create-artifact.sh"

# Create OCI source if it doesn't exist
if ! flux get source oci flux-system --context "$CONTEXT_NAME" >/dev/null 2>&1; then
  echo "Creating OCI source flux-system..."
  flux create source oci flux-system \
    --url="oci://k3d-reg-oci:5000/flux-system/gitops-repo" \
    --tag=latest \
    --interval=1m \
    --insecure \
    --context "$CONTEXT_NAME"
else
  flux reconcile source oci flux-system --context "$CONTEXT_NAME"
fi

if ! flux get kustomization local-bootstrap --context "$CONTEXT_NAME" >/dev/null 2>&1; then
  echo "Creating Kustomization local-bootstrap..."
  flux create kustomization local-bootstrap \
    --source=OCIRepository/flux-system \
    --path="./local-clusters/$CLUSTER_NAME/bootstrap" \
    --prune \
    --interval=2m \
    --context "$CONTEXT_NAME"
else
  flux reconcile kustomization local-bootstrap --context "$CONTEXT_NAME"
fi

# Build root Kustomization manifest
echo "Preparing Kustomization flux-system..."
KUSTOMIZATION_YAML=$(cat <<ENDOFYAML
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 10m
  path: ./clusters/$CLUSTER_NAME
  prune: true
  sourceRef:
    kind: OCIRepository
    name: flux-system
  patches:
    - target:
        kind: Kustomization
        group: kustomize.toolkit.fluxcd.io
      patch: |
        - op: replace
          path: /spec/sourceRef/kind
          value: OCIRepository
        - op: replace
          path: /spec/interval
          value: 2m
ENDOFYAML
)

# Merge per-cluster patches if any exist
PATCHES_DIR="$REPO_ROOT/local-clusters/$CLUSTER_NAME/patches"
if [[ -d "$PATCHES_DIR" ]]; then
  # Root-level patch files: direct patches on child Kustomization CRs
  for patch_file in "$PATCHES_DIR"/*.yaml "$PATCHES_DIR"/*.yml; do
    [[ -f "$patch_file" ]] || continue
    echo "  Adding patch from $(basename "$patch_file")"
    KUSTOMIZATION_YAML=$(echo "$KUSTOMIZATION_YAML" | yq '.spec.patches += [load("'"$patch_file"'")]')
  done

  # Subdirectory patches: directory name = target Kustomization name
  # Files are merged into a single strategic merge patch per Kustomization
  for kust_dir in "$PATCHES_DIR"/*/; do
    [[ -d "$kust_dir" ]] || continue
    KUST_NAME=$(basename "$kust_dir")

    # Collect spec.patches from all files into a combined document
    PATCH_DOC=$(yq -n '
      .apiVersion = "kustomize.toolkit.fluxcd.io/v1" |
      .kind = "Kustomization" |
      .metadata.name = "'"$KUST_NAME"'" |
      .spec.patches = []
    ')
    for patch_file in "$kust_dir"/*.yaml "$kust_dir"/*.yml; do
      [[ -f "$patch_file" ]] || continue
      echo "  Adding patch for $KUST_NAME from $(basename "$patch_file")"
      PATCH_DOC=$(echo "$PATCH_DOC" | yq '.spec.patches += (load("'"$patch_file"'") | .spec.patches)')
    done

    export PATCH_DOC
    KUSTOMIZATION_YAML=$(echo "$KUSTOMIZATION_YAML" | yq '
      .spec.patches += [{
        "target": {
          "kind": "Kustomization",
          "group": "kustomize.toolkit.fluxcd.io",
          "name": "'"$KUST_NAME"'"
        },
        "patch": strenv(PATCH_DOC)
      }]
    ')
  done
fi

# Apply or reconcile the Kustomization
if ! flux get kustomization flux-system --context "$CONTEXT_NAME" >/dev/null 2>&1; then
  echo "Creating Kustomization flux-system..."
  echo "$KUSTOMIZATION_YAML" | kubectl create --context "$CONTEXT_NAME" -f -
else
  DESIRED_PATCHES=$(echo "$KUSTOMIZATION_YAML" | yq -o=json '.spec.patches' - | jq -S .)
  CURRENT_PATCHES=$(kubectl get kustomization flux-system -n flux-system --context "$CONTEXT_NAME" -o yaml | yq -o=json '.spec.patches' - | jq -S .)
  if [[ "$DESIRED_PATCHES" != "$CURRENT_PATCHES" ]]; then
    echo "Patches changed, reapplying Kustomization flux-system..."
    echo "$KUSTOMIZATION_YAML" | kubectl apply --context "$CONTEXT_NAME" -f -
  else
    flux reconcile kustomization flux-system --context "$CONTEXT_NAME"
  fi
fi

# Apply clustermesh CA secret for cert-manager ClusterIssuer
echo "Applying clustermesh CA secret..."
kubectl create secret tls clustermesh-ca \
  --cert="$CLUSTERMESH_CA_DIR/tls.crt" \
  --key="$CLUSTERMESH_CA_DIR/tls.key" \
  --namespace=cert-manager \
  --context "$CONTEXT_NAME" \
  --dry-run=client -o yaml | kubectl apply --context "$CONTEXT_NAME" -f -

echo "Flux bootstrap complete for $CLUSTER_NAME"
