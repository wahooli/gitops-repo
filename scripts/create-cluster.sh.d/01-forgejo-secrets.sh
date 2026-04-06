#!/usr/bin/env bash

set -euo pipefail

# Generate shared forgejo secrets (once, reused across all clusters)
FORGEJO_SECRETS_DIR="$REPO_ROOT/local-clusters/.forgejo-secrets"

if [[ -f "$FORGEJO_SECRETS_DIR/jwt-secret" && -f "$FORGEJO_SECRETS_DIR/ssh_host_ed25519_key" ]]; then
  echo "Using existing forgejo secrets from local-clusters/.forgejo-secrets/"
  exit 0
fi

echo "Generating shared forgejo secrets..."
mkdir -p "$FORGEJO_SECRETS_DIR"

# JWT RSA private key
openssl genpkey -algorithm RSA -out "$FORGEJO_SECRETS_DIR/jwt-secret" -pkeyopt rsa_keygen_bits:4096

# SSH host keys
ssh-keygen -t ed25519 -f "$FORGEJO_SECRETS_DIR/ssh_host_ed25519_key" -N "" -C ""
ssh-keygen -t ecdsa -f "$FORGEJO_SECRETS_DIR/ssh_host_ecdsa_key" -N "" -C ""
ssh-keygen -t rsa -b 4096 -f "$FORGEJO_SECRETS_DIR/ssh_host_rsa_key" -N "" -C ""

# App secrets (random tokens)
openssl rand -base64 32 | tr -d '\n' > "$FORGEJO_SECRETS_DIR/secret-key"
openssl rand -base64 64 | tr -d '\n' > "$FORGEJO_SECRETS_DIR/internal-token"
openssl rand -base64 32 | tr -d '\n' > "$FORGEJO_SECRETS_DIR/oauth2-jwt-secret"
openssl rand -base64 32 | tr -d '\n' > "$FORGEJO_SECRETS_DIR/lfs-jwt-secret"

# Anubis ed25519 private key (hex-encoded)
openssl rand -hex 32 | tr -d '\n' > "$FORGEJO_SECRETS_DIR/anubis-private-key"
