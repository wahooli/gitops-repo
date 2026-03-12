#!/usr/bin/env bash

set -euo pipefail

# Copy clustermesh CA into cluster bootstrap directory and generate secret kustomization
CLUSTERMESH_CA_SRC="$REPO_ROOT/local-clusters/.clustermesh-ca"
CLUSTERMESH_CA_DIR="$REPO_ROOT/local-clusters/$CLUSTER_NAME/bootstrap/clustermesh-ca"

if [[ ! -f "$CLUSTERMESH_CA_SRC/tls.crt" || ! -f "$CLUSTERMESH_CA_SRC/tls.key" ]]; then
  echo "No clustermesh CA found in local-clusters/.clustermesh-ca/, skipping"
  exit 0
fi

mkdir -p "$CLUSTERMESH_CA_DIR"

cp "$CLUSTERMESH_CA_SRC/tls.crt" "$CLUSTERMESH_CA_DIR/"
cp "$CLUSTERMESH_CA_SRC/tls.key" "$CLUSTERMESH_CA_DIR/"

cat > "$CLUSTERMESH_CA_DIR/kustomization.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: cert-manager
generatorOptions:
  disableNameSuffixHash: true
secretGenerator:
- name: clustermesh-ca
  type: kubernetes.io/tls
  files:
  - tls.crt
  - tls.key
EOF
