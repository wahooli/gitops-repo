#!/usr/bin/env bash

set -euo pipefail

# Copy shared forgejo secrets into cluster-specific bootstrap directory and generate kustomization
FORGEJO_SECRETS_SRC="$REPO_ROOT/local-clusters/.forgejo-secrets"
FORGEJO_SECRETS_DIR="$REPO_ROOT/local-clusters/$CLUSTER_NAME/bootstrap/forgejo-secrets"

if [[ ! -d "$FORGEJO_SECRETS_SRC" ]]; then
  echo "No forgejo secrets found in local-clusters/.forgejo-secrets/, skipping"
  exit 0
fi

if [[ ! -f "$REPO_ROOT/local-clusters/$CLUSTER_NAME/bootstrap/namespaces/forgejo.yaml" ]]; then
  echo "Cluster $CLUSTER_NAME does not have forgejo namespace, skipping forgejo secrets"
  exit 0
fi

mkdir -p "$FORGEJO_SECRETS_DIR"

# Copy all secret files
cp "$FORGEJO_SECRETS_SRC"/jwt-secret "$FORGEJO_SECRETS_DIR/"
cp "$FORGEJO_SECRETS_SRC"/ssh_host_* "$FORGEJO_SECRETS_DIR/"
cp "$FORGEJO_SECRETS_SRC"/secret-key "$FORGEJO_SECRETS_DIR/"
cp "$FORGEJO_SECRETS_SRC"/internal-token "$FORGEJO_SECRETS_DIR/"
cp "$FORGEJO_SECRETS_SRC"/oauth2-jwt-secret "$FORGEJO_SECRETS_DIR/"
cp "$FORGEJO_SECRETS_SRC"/lfs-jwt-secret "$FORGEJO_SECRETS_DIR/"
cp "$FORGEJO_SECRETS_SRC"/anubis-private-key "$FORGEJO_SECRETS_DIR/"

cat > "$FORGEJO_SECRETS_DIR/kustomization.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: forgejo
generatorOptions:
  disableNameSuffixHash: true
secretGenerator:
- name: forgejo-shared-keys
  files:
  - jwt-secret
  - ssh_host_ed25519_key
  - ssh_host_ed25519_key.pub
  - ssh_host_ecdsa_key
  - ssh_host_ecdsa_key.pub
  - ssh_host_rsa_key
  - ssh_host_rsa_key.pub
- name: forgejo-app-secrets
  files:
  - secret-key
  - internal-token
  - oauth2-jwt-secret
  - lfs-jwt-secret
- name: anubis-secret
  files:
  - private-key=anubis-private-key
EOF
