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

mapfile -t expected_devices < <(grep -oE 'forgejo_syncthing_device_[a-z0-9_]+' "$REPO_ROOT/apps/shared/forgejo/syncthing-config.xml" | sort -u)
for var in "${expected_devices[@]}"; do
  name="${var#forgejo_syncthing_device_}"
  for dir in "$REPO_ROOT"/local-clusters/*/; do
    if [[ "$(basename "$dir" | tr - _)" == "$name" ]]; then
      name=$(basename "$dir")
      break
    fi
  done
  if [[ ! -f "$SYNCTHING_DEVICES_DIR/$name.txt" ]]; then
    echo "No syncthing device ID for $name, generating a placeholder"
    docker run --rm --entrypoint sh syncthing/syncthing:1.27 -c \
      'syncthing generate --home=/tmp/st --skip-port-probing >/dev/null 2>&1 && syncthing --device-id --home=/tmp/st' \
      > "$SYNCTHING_DEVICES_DIR/$name.txt"
  fi
done

# Generate kustomization.yaml with secretGenerator referencing all device ID files
# Keys are named syncthing_device_<cluster> (dashes converted to underscores)
FILES_YAML=""
for f in "$SYNCTHING_DEVICES_DIR"/*.txt; do
  name=$(basename "$f" .txt)
  for app in forgejo immich; do
    key="${app}_syncthing_device_${name//-/_}"
    FILES_YAML="${FILES_YAML}  - ${key}=$(basename "$f")"$'\n'
  done
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
