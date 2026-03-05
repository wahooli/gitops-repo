#!/usr/bin/env bash

set -euo pipefail

# Get script and repo root directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Argument parsing & validation ---
CLUSTER_NAME="${1:-}"
if [[ -z "$CLUSTER_NAME" ]]; then
  echo "Usage: $0 <cluster-name>"
  exit 1
fi

# Delete the k3d cluster
if k3d cluster get "$CLUSTER_NAME" >/dev/null 2>&1; then
  echo "Deleting cluster $CLUSTER_NAME..."
  k3d cluster delete "$CLUSTER_NAME"
fi

# Stop extra containers from containers.yaml if it exists
CONTAINERS_CONFIG="$REPO_ROOT/local-clusters/$CLUSTER_NAME/containers.yaml"
if [[ -f "$CONTAINERS_CONFIG" ]]; then
  CONTAINER_COUNT=$(yq 'length' "$CONTAINERS_CONFIG")
  for i in $(seq 0 $((CONTAINER_COUNT - 1))); do
    CONTAINER_NAME=$(yq -r ".[$i].name" "$CONTAINERS_CONFIG")

    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
      echo "Removing container $CONTAINER_NAME..."
      docker rm -f "$CONTAINER_NAME"
    fi
  done
fi
