#!/usr/bin/env bash

set -euo pipefail

# Get script and repo root directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IN_DEVCONTAINER="${IN_DEVCONTAINER:-false}"
OCI_REGISTRY_NAME="reg-oci"
OCI_REGISTRY_PORT=5050

if [[ "${IN_DEVCONTAINER,,}" == "true" ]]; then
  OCI_URL="oci://k3d-${OCI_REGISTRY_NAME}:5000/flux-system/gitops-repo"
else
  OCI_URL="oci://127.0.0.1:${OCI_REGISTRY_PORT}/flux-system/gitops-repo"
fi

echo "Pushing manifests to OCI registry..."
flux push artifact "$OCI_URL:latest" \
  --path="$REPO_ROOT" \
  --source="local" \
  --revision="local@$(date +%s)" \
  --insecure-registry \
  --ignore-paths="clusters/*/flux-system/"

echo "Done."
