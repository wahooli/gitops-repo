#!/usr/bin/env bash

set -euo pipefail

# Generate syncthing keys (per-cluster, for forgejo HA sync)
SYNCTHING_KEYS_DIR="$REPO_ROOT/local-clusters/$CLUSTER_NAME/bootstrap/syncthing-keys"
if [[ ! -f "$SYNCTHING_KEYS_DIR/cert.pem" || ! -f "$SYNCTHING_KEYS_DIR/key.pem" ]]; then
  echo "Generating syncthing keys for $CLUSTER_NAME..."
  mkdir -p "$SYNCTHING_KEYS_DIR"
  docker run --rm -u "$(id -u):$(id -g)" -v "$SYNCTHING_KEYS_DIR:/output" --entrypoint sh syncthing/syncthing:1.27 -c '
    syncthing generate --home=/tmp/st --skip-port-probing
    cp /tmp/st/cert.pem /tmp/st/key.pem /output/
    syncthing --device-id --home=/tmp/st > /output/device-id.txt
  '
else
  echo "Using existing syncthing keys from local-clusters/$CLUSTER_NAME/bootstrap/syncthing-keys/"
fi

# Generate kustomization for syncthing-keys secret
if [[ ! -f "$SYNCTHING_KEYS_DIR/kustomization.yaml" ]]; then
  cat > "$SYNCTHING_KEYS_DIR/kustomization.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: forgejo
generatorOptions:
  disableNameSuffixHash: true
secretGenerator:
- name: syncthing-keys
  files:
  - cert.pem
  - key.pem
EOF
fi

# Copy device ID to shared directory for cross-cluster reference
SYNCTHING_DEVICES_DIR="$REPO_ROOT/local-clusters/.syncthing-devices"
mkdir -p "$SYNCTHING_DEVICES_DIR"
cp "$SYNCTHING_KEYS_DIR/device-id.txt" "$SYNCTHING_DEVICES_DIR/$CLUSTER_NAME.txt"
