#!/usr/bin/env bash

set -euo pipefail

# Get script and repo root directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

OCI_URL="oci://127.0.0.1:5050/flux-system/gitops-repo"

echo "Pushing manifests to OCI registry..."
flux push artifact "$OCI_URL:latest" \
  --path="$REPO_ROOT" \
  --source="local" \
  --revision="local@$(date +%s)" \
  --ignore-paths="clusters/*/flux-system/"

echo "Done."
