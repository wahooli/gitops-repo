#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Discover deployable clusters
# A cluster is deployable if:
#   - local-clusters/<name>/k3d-config.yaml exists
#   - clusters/<name>/ exists
#   - name doesn't start with _ or .
clusters=()
for dir in "$REPO_ROOT"/local-clusters/*/; do
  [[ -d "$dir" ]] || continue
  name=$(basename "$dir")
  [[ "$name" == _* || "$name" == .* ]] && continue
  [[ -f "$dir/k3d-config.yaml" ]] || continue
  [[ -d "$REPO_ROOT/clusters/$name" ]] || continue
  clusters+=("$name")
done

if (( ${#clusters[@]} == 0 )); then
  echo "No deployable clusters found" >&2
  exit 1
fi

echo "Clusters to deploy: ${clusters[*]}"

# --- Exit early if all clusters are already running ---
all_up=true
for cluster in "${clusters[@]}"; do
  if ! k3d cluster list -o json | jq -e ".[] | select(.name==\"$cluster\")" >/dev/null 2>&1; then
    all_up=false
    break
  fi
done

if [[ "$all_up" == true ]]; then
  echo "All clusters are already running"
  exit 0
fi

# --- Create all clusters in parallel ---
declare -A create_pids=()
echo "Creating clusters in parallel..."
for cluster in "${clusters[@]}"; do
  echo "  Creating $cluster"
  "$SCRIPT_DIR/create-cluster.sh" "$cluster" &
  create_pids["$cluster"]=$!
  sleep 2
done

echo "Waiting for cluster creation..."
for cluster in "${clusters[@]}"; do
  if ! wait "${create_pids[$cluster]}"; then
    echo "Failed to create cluster $cluster" >&2
    exit 1
  fi
  echo "  $cluster ready"
done

# --- Sync cilium-ca across all clusters (idempotent) ---
if (( ${#clusters[@]} > 1 )); then
  CILIUM_CA_DIR="$REPO_ROOT/local-clusters/.cilium-ca"
  mkdir -p "$CILIUM_CA_DIR"
  CA_SECRET_FILE="$CILIUM_CA_DIR/cilium-ca.yaml"

  # Export cilium-ca from the first cluster if not cached on disk
  if [[ ! -f "$CA_SECRET_FILE" ]]; then
    primary="${clusters[0]}"
    echo "Exporting cilium-ca from $primary to $CILIUM_CA_DIR..."
    kubectl --context "k3d-${primary}" -n kube-system get secret cilium-ca -o yaml | \
      yq 'del(.metadata.resourceVersion, .metadata.uid, .metadata.creationTimestamp, .metadata.managedFields, .metadata.annotations)' \
      > "$CA_SECRET_FILE"
  else
    echo "Using cached cilium-ca from $CILIUM_CA_DIR"
  fi

  desired_data=$(yq -o=json '.data' "$CA_SECRET_FILE" | jq -S .)

  # Apply to each cluster, only restart if the secret data changed
  restart_clusters=()
  for cluster in "${clusters[@]}"; do
    current_data=$(kubectl --context "k3d-${cluster}" -n kube-system get secret cilium-ca \
      -o json 2>/dev/null | jq -S '.data' || echo "{}")

    if [[ "$current_data" != "$desired_data" ]]; then
      echo "  Updating cilium-ca in $cluster"
      kubectl --context "k3d-${cluster}" -n kube-system delete secret cilium-ca --ignore-not-found
      kubectl --context "k3d-${cluster}" -n kube-system apply -f "$CA_SECRET_FILE"
      restart_clusters+=("$cluster")
    else
      echo "  cilium-ca already in sync on $cluster"
    fi
  done

  if (( ${#restart_clusters[@]} > 0 )); then
    echo "Restarting Cilium on clusters with updated CA..."
    for cluster in "${restart_clusters[@]}"; do
      echo "  Restarting cilium in $cluster"
      kubectl --context "k3d-${cluster}" -n kube-system rollout restart deployment/cilium-operator
      kubectl --context "k3d-${cluster}" -n kube-system rollout restart daemonset/cilium
    done

    for cluster in "${restart_clusters[@]}"; do
      echo "  Waiting for cilium rollout in $cluster..."
      kubectl --context "k3d-${cluster}" -n kube-system rollout status deployment/cilium-operator --timeout=300s
      kubectl --context "k3d-${cluster}" -n kube-system rollout status daemonset/cilium --timeout=300s
    done
  fi
fi

# --- Connect all cluster pairs via ClusterMesh ---
if (( ${#clusters[@]} < 2 )); then
  echo "Single cluster deployed, skipping ClusterMesh connections"

  # Bootstrap Flux on single cluster
  echo "Bootstrapping Flux on ${clusters[0]}..."
  "$SCRIPT_DIR/bootstrap-flux.sh" "${clusters[0]}"
  exit 0
fi

get_clustermesh_endpoint() {
  local context="k3d-$1"
  local ip port

  # Wait for LoadBalancer external IP to be assigned
  until ip=$(kubectl --context "$context" -n kube-system get svc clustermesh-apiserver \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}') && [[ -n "$ip" ]]; do
    sleep 3
  done

  echo "  Found ClusterMesh API server IP for $1: $ip" >&2
  port=$(kubectl --context "$context" -n kube-system get svc clustermesh-apiserver \
    -o jsonpath='{.spec.ports[0].port}')
  echo "${ip}:${port}"
}

echo "Connecting clusters via ClusterMesh..."

# Wait for clustermesh-apiserver on all clusters
for cluster in "${clusters[@]}"; do
  echo "  Waiting for clustermesh-apiserver in $cluster..."
  until kubectl --context "k3d-${cluster}" -n kube-system get deployment clustermesh-apiserver >/dev/null 2>&1; do
    sleep 5
  done
  kubectl --context "k3d-${cluster}" -n kube-system rollout status deployment/clustermesh-apiserver --timeout=120s
done

# Connect every unique pair (before Flux bootstrap to avoid IP pool conflicts)
for ((i = 0; i < ${#clusters[@]}; i++)); do
  for ((j = i + 1; j < ${#clusters[@]}; j++)); do
    cluster_a="${clusters[$i]}"
    cluster_b="${clusters[$j]}"
    echo "  Connecting $cluster_a <-> $cluster_b"

    src_endpoint=$(get_clustermesh_endpoint "$cluster_a")
    dst_endpoint=$(get_clustermesh_endpoint "$cluster_b")

    cilium clustermesh connect \
      --context "k3d-${cluster_a}" \
      --destination-context "k3d-${cluster_b}" \
      --source-endpoint "$src_endpoint" \
      --destination-endpoint "$dst_endpoint"
  done
done

# --- Wait for ClusterMesh to be fully established ---
echo "Waiting for ClusterMesh status on all clusters..."
for cluster in "${clusters[@]}"; do
  echo "  Checking clustermesh status in $cluster..."
  cilium clustermesh status --context "k3d-${cluster}" --wait
done

# --- Bootstrap Flux on each cluster (sequential — shares OCI artifact) ---
echo "Bootstrapping Flux on all clusters..."
for cluster in "${clusters[@]}"; do
  echo "  Bootstrapping $cluster"
  HELM_VALUES_PATH=extra-helm-values-mesh "$SCRIPT_DIR/bootstrap-flux.sh" "$cluster"
done

echo "All clusters created and connected via ClusterMesh"
