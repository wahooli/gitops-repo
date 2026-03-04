# Kubernetes clusters

Multi-cluster Kubernetes GitOps repository managing clusters (`nas`, `tpi-1`, `livingroom-pi`) using [Flux](https://fluxcd.io/) and [Cilium ClusterMesh](https://docs.cilium.io/en/stable/network/clustermesh/). Clusters are provisioned with [Ansible](https://www.ansible.com/). [k3d](https://k3d.io/) is used to spin up local replicas of the clusters for development and testing.

## Prerequisites

The recommended way to work with this repo is via the provided [dev container](#dev-container). If running outside of it, you need:

- Docker
- kubectl, helm, k3d, flux CLI, cilium CLI, jq, yq

## Dev container

A VS Code dev container is provided at [.devcontainer/](.devcontainer/). It automatically installs all required tools and joins the `k3d-multicluster-net` Docker network so it can communicate directly with k3d clusters.

Open the repo in VS Code and select **Reopen in Container** when prompted.

The `IN_DEVCONTAINER=true` environment variable is set automatically inside the container and used by scripts to select the correct registry and kubeconfig addresses.

## Repository structure

```
clusters/           Flux manifests per cluster (sources, kustomizations)
local-clusters/     k3d configs and local bootstrap/Helm value overrides
apps/               Application Helm releases — base definitions + per-cluster overrides
infrastructure/     Infrastructure components — base definitions + per-cluster overrides
                    (CNI, ingress, storage, DNS, monitoring…)
scripts/            Automation scripts
.devcontainer/      Dev container configuration
```

## Local development

### Makefile targets

```
make deploy <cluster>               Create k3d cluster and bootstrap Flux
make deploy mesh                    Deploy all clusters and connect via ClusterMesh
make create <cluster>               Create k3d cluster only
make bootstrap <cluster>            Bootstrap Flux only
make artifact                       Push manifests to local OCI registry
make down [cluster]                 Delete k3d cluster (all clusters if omitted)
make verify <cluster>               Verify kustomizations, HelmReleases and workloads
make verify-kustomization <cluster> Verify Flux kustomization reconciliation
make verify-helmrelease <cluster>   Verify HelmRelease reconciliation
make verify-workload <cluster>      Verify all workloads are healthy
make lint                           Run yamllint across the repo
```

Available clusters are the directories under `clusters/`.

### Scripts

| Script | Description |
|---|---|
| `scripts/create-cluster.sh` | Creates k3d cluster, Docker network, pull-through and OCI registries, installs Cilium |
| `scripts/bootstrap-flux.sh` | Pushes OCI artifact and bootstraps Flux kustomizations on a cluster |
| `scripts/deploy-mesh.sh` | Orchestrates all clusters and syncs Cilium CA across them for ClusterMesh |
| `scripts/create-artifact.sh` | Pushes repo manifests to the local OCI registry |
| `scripts/delete-cluster.sh` | Tears down a cluster and its associated containers |

## Secrets and Ansible

Enable git hooks to automatically decrypt secrets on checkout:

```sh
git config core.hooksPath .githooks/
```

Requires `ansible-vault` to be installed and a `vault-password.txt` file in the repo root containing the decryption key. To manually decrypt values run:

```sh
.githooks/post-checkout
```

Install the required Ansible collection:

```sh
ansible-galaxy collection install git@github.com:wahooli/ansible-collection-common.git
```

Fetch kubeconfig from a live cluster:

```sh
ansible-playbook wahooli.common.fetch_kubeconfig -i inventory/vm/
export KUBECONFIG="$(pwd)/output/kubeconfig"
```

Update cluster secrets:

```sh
ansible-playbook wahooli.common.update_cluster_secrets -i inventory/vm/
```
