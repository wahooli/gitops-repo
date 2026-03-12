#!/usr/bin/env bash

set -euo pipefail

# Generate clustermesh CA certificate (shared across all clusters)
CLUSTERMESH_CA_DIR="$REPO_ROOT/local-clusters/.clustermesh-ca"

if [[ -f "$CLUSTERMESH_CA_DIR/tls.crt" && -f "$CLUSTERMESH_CA_DIR/tls.key" ]]; then
  echo "Using existing clustermesh CA from local-clusters/.clustermesh-ca/"
  exit 0
fi

echo "Generating clustermesh CA certificate..."
mkdir -p "$CLUSTERMESH_CA_DIR"
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
  -keyout "$CLUSTERMESH_CA_DIR/tls.key" \
  -out "$CLUSTERMESH_CA_DIR/tls.crt" \
  -days 3650 -nodes \
  -subj "/CN=clustermesh-ca"
