#!/usr/bin/env bash

set -euo pipefail

# Get script and repo root directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CILIUM_VERSION="1.19.1"
REGISTRY_NAME="reg-docker"
REGISTRY_PORT=5000
USE_DEFAULT_REGISTRY=0

OCI_REGISTRY_NAME="reg-oci"
OCI_REGISTRY_PORT=5050

# --- Argument parsing & validation ---
CLUSTER_NAME="${1:-}"
if [[ -z "$CLUSTER_NAME" ]]; then
  echo "Usage: $0 <cluster-name>"
  echo ""
  echo "Available clusters:"
  for dir in "$REPO_ROOT"/clusters/*/; do
    [[ -d "$dir" ]] && echo "  $(basename "$dir")"
  done
  exit 1
fi

# Validate cluster directory exists
if [[ ! -d "$REPO_ROOT/clusters/$CLUSTER_NAME" ]]; then
  echo "Error: No cluster directory found at clusters/$CLUSTER_NAME"
  echo ""
  echo "Available clusters:"
  for dir in "$REPO_ROOT"/clusters/*/; do
    [[ -d "$dir" ]] && echo "  $(basename "$dir")"
  done
  exit 1
fi

# Validate k3d config exists
K3D_CONFIG="$REPO_ROOT/local-clusters/$CLUSTER_NAME/k3d-config.yaml"
if [[ ! -f "$K3D_CONFIG" ]]; then
  echo "Error: k3d config not found at local-clusters/$CLUSTER_NAME/k3d-config.yaml"
  exit 1
fi

# Validate metadata.name matches cluster name argument
CONFIG_NAME=$(yq '.metadata.name' "$K3D_CONFIG")
if [[ "$CONFIG_NAME" != "$CLUSTER_NAME" ]]; then
  echo "Error: metadata.name in k3d config ('$CONFIG_NAME') does not match cluster name ('$CLUSTER_NAME')"
  exit 1
fi

CONTEXT_NAME="k3d-${CLUSTER_NAME}"

# Read network name from k3d config
DOCKER_NETWORK=$(yq '.network // "k3d-multicluster-net"' "$K3D_CONFIG")

# Exit if cluster already exists
if k3d cluster list -o json | jq -e ".[] | select(.name==\"$CLUSTER_NAME\")" >/dev/null 2>&1; then
  echo "Cluster $CLUSTER_NAME already exists, skipping creation"
  exit 0
fi

# Create Docker network if not exists
if ! docker network inspect "$DOCKER_NETWORK" >/dev/null 2>&1; then
  echo "Creating Docker network $DOCKER_NETWORK..."
  docker network create "$DOCKER_NETWORK"
else
  echo "Docker network $DOCKER_NETWORK already exists"
fi

# Deploy extra containers from containers.yaml if it exists
CONTAINERS_CONFIG="$REPO_ROOT/local-clusters/$CLUSTER_NAME/containers.yaml"
if [[ -f "$CONTAINERS_CONFIG" ]]; then
  CONTAINER_COUNT=$(yq 'length' "$CONTAINERS_CONFIG")
  for i in $(seq 0 $((CONTAINER_COUNT - 1))); do
    CONTAINER_NAME=$(yq -r ".[$i].name" "$CONTAINERS_CONFIG")
    CONTAINER_IMAGE=$(yq -r ".[$i].image" "$CONTAINERS_CONFIG")
    CONTAINER_ARGS=$(yq -r ".[$i].args // \"\"" "$CONTAINERS_CONFIG")

    # Build network alias flags
    ALIAS_ARGS=()
    while IFS= read -r alias; do
      [[ -n "$alias" ]] && ALIAS_ARGS+=(--network-alias "$alias")
    done < <(yq -r ".[$i].networkAliases // [] | .[]" "$CONTAINERS_CONFIG")

    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
      if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Starting existing container $CONTAINER_NAME..."
        docker start "$CONTAINER_NAME"
      else
        echo "Container $CONTAINER_NAME is already running"
      fi
    else
      echo "Creating container $CONTAINER_NAME ($CONTAINER_IMAGE)..."
      docker run -d --name "$CONTAINER_NAME" \
        --network "$DOCKER_NETWORK" \
        "${ALIAS_ARGS[@]}" \
        $CONTAINER_ARGS \
        "$CONTAINER_IMAGE"
    fi
  done
fi

# Create registry config for pull-through cache
REGISTRY_PROXY_CONFIG="$REPO_ROOT/local-clusters/.registry"
mkdir -p "$REGISTRY_PROXY_CONFIG"
cat > "$REGISTRY_PROXY_CONFIG/config.yml" <<'REGCONF'
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
proxy:
  remoteurl: https://registry-1.docker.io
REGCONF

# Create the registry if it doesn't exist
REGISTRY_CONTAINER="k3d-$REGISTRY_NAME"

# Check if the docker container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${REGISTRY_CONTAINER}$"; then
  # Container exists, check if it's running
  if ! docker ps --format '{{.Names}}' | grep -q "^${REGISTRY_CONTAINER}$"; then
    echo "Starting existing registry container $REGISTRY_CONTAINER..."
    docker start "$REGISTRY_CONTAINER"
  else
    echo "Registry container $REGISTRY_CONTAINER is already running"
  fi
elif ! k3d registry list | grep -q "$REGISTRY_NAME"; then
  # Container doesn't exist and not in k3d registry list, create it
  echo "Creating registry $REGISTRY_NAME on port $REGISTRY_PORT as pull-through cache..."
  if [[ "${USE_DEFAULT_REGISTRY:-0}" -eq 1 ]]; then
    k3d registry create "$REGISTRY_NAME" \
      --default-network "$DOCKER_NETWORK" \
      -p "$REGISTRY_PORT" \
      -v "k3d-$REGISTRY_NAME-data:/var/lib/registry" \
      -v "$REGISTRY_PROXY_CONFIG/config.yml:/etc/docker/registry/config.yml"
  else
    k3d registry create "$REGISTRY_NAME" \
      -i ligfx/k3d-registry-dockerd:v0.10 \
      -p "$REGISTRY_PORT" \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --proxy-remote-url "*"
  fi
else
  echo "Using existing registry $REGISTRY_NAME"
fi

# Create OCI registry (standard registry:2) for flux artifacts
OCI_REGISTRY_CONTAINER="k3d-$OCI_REGISTRY_NAME"

if docker ps -a --format '{{.Names}}' | grep -q "^${OCI_REGISTRY_CONTAINER}$"; then
  if ! docker ps --format '{{.Names}}' | grep -q "^${OCI_REGISTRY_CONTAINER}$"; then
    echo "Starting existing OCI registry container $OCI_REGISTRY_CONTAINER..."
    docker start "$OCI_REGISTRY_CONTAINER"
  else
    echo "OCI registry container $OCI_REGISTRY_CONTAINER is already running"
  fi
elif ! k3d registry list | grep -q "$OCI_REGISTRY_NAME"; then
  echo "Creating OCI registry $OCI_REGISTRY_NAME on port $OCI_REGISTRY_PORT..."
  k3d registry create "$OCI_REGISTRY_NAME" \
    --default-network "$DOCKER_NETWORK" \
    -p "$OCI_REGISTRY_PORT"
else
  echo "Using existing OCI registry $OCI_REGISTRY_NAME"
fi

# Create the k3d cluster using config file
echo "Creating k3d cluster: $CLUSTER_NAME"
k3d cluster create --config "$K3D_CONFIG"

# Mount BPF filesystem in all nodes
echo "Mounting bpffs in k3d containers"
NODES=$(docker ps --filter "name=k3d-$CLUSTER_NAME" --format "{{.Names}}")
for node in $NODES; do
  echo "  Mounting /sys/fs/bpf in $node"
  docker exec "$node" sh -c '
    mkdir -p /sys/fs/bpf
    mount bpffs /sys/fs/bpf -t bpf || echo "    (already mounted)"
    mount --make-shared /sys/fs/bpf || true
  '
done

# Ensure /etc/machine-id and /run/log/journal exist in all nodes (needed by Vector agent for journald)
echo "Ensuring /etc/machine-id and /run/log/journal exist in k3d containers"
for node in $NODES; do
  docker exec "$node" sh -c '
    if [ ! -f /etc/machine-id ]; then
      echo "  Creating /etc/machine-id in '"$node"'"
      cat /proc/sys/kernel/random/uuid | tr -d "-" > /etc/machine-id
    fi
    mkdir -p /run/log/journal
  '
done

# Install NFS mount wrapper in all nodes (unfs3 only supports NFSv3, but
# busybox mount defaults to NFSv4 which results in "Connection refused")
echo "Installing NFS mount wrapper in k3d containers"
for node in $NODES; do
  docker exec "$node" sh -c '
    mkdir -p /usr/local/bin
    cat > /usr/local/bin/mount <<"MOUNTSCRIPT"
#!/bin/sh
# Wrapper to force NFSv3 for NFS mounts (unfs3 compatibility)
nfs_mount=0
prev_was_t=0
for arg in "$@"; do
  if [ "$prev_was_t" = "1" ] && [ "$arg" = "nfs" ]; then
    nfs_mount=1
  fi
  prev_was_t=0
  if [ "$arg" = "-t" ]; then
    prev_was_t=1
  fi
done

if [ "$nfs_mount" = "1" ]; then
  has_vers=0
  for arg in "$@"; do
    case "$arg" in *vers=*|*nfsvers=*) has_vers=1 ;; esac
  done
  if [ "$has_vers" = "0" ]; then
    exec /bin/aux/mount "$@" -o vers=3,nolock,tcp
  fi
fi
exec /bin/aux/mount "$@"
MOUNTSCRIPT
    chmod +x /usr/local/bin/mount
  '
done

# Install Cilium via Helm
echo "Installing Cilium in cluster $CLUSTER_NAME"

CILIUM_BASE_VALUES="$REPO_ROOT/local-clusters/cilium-base-values.yaml"
CILIUM_CLUSTER_VALUES="$REPO_ROOT/local-clusters/$CLUSTER_NAME/cilium-values.yaml"

HELM_ARGS=(
  upgrade --install cilium cilium
  --repo https://helm.cilium.io
  --namespace kube-system
  --version "$CILIUM_VERSION"
  --kube-context "$CONTEXT_NAME"
)

if [[ -f "$CILIUM_BASE_VALUES" ]]; then
  HELM_ARGS+=(-f "$CILIUM_BASE_VALUES")
fi

if [[ -f "$CILIUM_CLUSTER_VALUES" ]]; then
  HELM_ARGS+=(-f "$CILIUM_CLUSTER_VALUES")
fi

helm "${HELM_ARGS[@]}"

echo "Cilium installed successfully in $CLUSTER_NAME"

kubectl --context "$CONTEXT_NAME" create -f "$REPO_ROOT/clusters/$CLUSTER_NAME/flux-system/gotk-components.yaml"

echo "FluxCD installed successfully in $CLUSTER_NAME"

# Wait for Cilium rollouts (disable with SKIP_WAIT=1)
if [[ "${SKIP_WAIT:-0}" -ne 1 ]]; then
  echo "Waiting for Cilium rollouts in $CLUSTER_NAME..."
  kubectl rollout status deployment/cilium-operator --namespace kube-system --context "$CONTEXT_NAME" --timeout=300s
  kubectl rollout status daemonset/cilium --namespace kube-system --context "$CONTEXT_NAME" --timeout=300s
  kubectl rollout status daemonset/cilium-envoy --namespace kube-system --context "$CONTEXT_NAME" --timeout=300s
  echo "All Cilium components are ready in $CLUSTER_NAME"
  kubectl rollout status deployment/source-controller --namespace flux-system --context "$CONTEXT_NAME" --timeout=300s
  kubectl rollout status deployment/kustomize-controller --namespace flux-system --context "$CONTEXT_NAME" --timeout=300s
  kubectl rollout status deployment/notification-controller --namespace flux-system --context "$CONTEXT_NAME" --timeout=300s
  kubectl rollout status deployment/helm-controller --namespace flux-system --context "$CONTEXT_NAME" --timeout=300s
  echo "All FluxCD components are ready in $CLUSTER_NAME"
fi
