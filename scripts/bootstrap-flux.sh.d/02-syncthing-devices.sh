#!/usr/bin/env bash

set -euo pipefail

# Copy syncthing device IDs into cluster-specific bootstrap directory and generate secret
SYNCTHING_DEVICES_SRC="$REPO_ROOT/local-clusters/.syncthing-devices"
SYNCTHING_DEVICES_DIR="$REPO_ROOT/local-clusters/$CLUSTER_NAME/bootstrap/syncthing-devices"

if [[ ! -d "$SYNCTHING_DEVICES_SRC" ]] || ! ls "$SYNCTHING_DEVICES_SRC"/*.txt >/dev/null 2>&1; then
  echo "No syncthing device IDs found in local-clusters/.syncthing-devices/, skipping"
  exit 0
fi

mkdir -p "$SYNCTHING_DEVICES_DIR"

# Copy all device ID files
cp "$SYNCTHING_DEVICES_SRC"/*.txt "$SYNCTHING_DEVICES_DIR/"

# Generate kustomization.yaml with secretGenerator referencing all device ID files
# Keys are named syncthing_device_<cluster> (dashes converted to underscores)
FILES_YAML=""
for f in "$SYNCTHING_DEVICES_DIR"/*.txt; do
  name=$(basename "$f" .txt)
  key="syncthing_device_${name//-/_}"
  FILES_YAML="${FILES_YAML}  - ${key}=$(basename "$f")"$'\n'
done

# Remove trailing newline to prevent stray line in heredoc
FILES_YAML="${FILES_YAML%$'\n'}"

cat > "$SYNCTHING_DEVICES_DIR/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: flux-system
generatorOptions:
  disableNameSuffixHash: true
secretGenerator:
- name: syncthing-devices
  files:
${FILES_YAML}
EOF
