---
title: "platform resources"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

## Overview

The `ci-excluded` resource in the `platform` infrastructure layer for the `tpi-1` cluster is a Flux Kustomization. It is responsible for managing the deployment of Kubernetes manifests located in the specified path within the Git repository. This resource ensures that the manifests are applied to the cluster, reconciled at regular intervals, and pruned when necessary. It also supports variable substitution using secrets to dynamically configure the manifests at deploy time.

## Resource Glossary

### Kustomization: `ci-excluded`
- **Kind**: `Kustomization`
- **Name**: `ci-excluded`
- **Namespace**: `flux-system`
- **Purpose**: This resource manages the deployment of Kubernetes manifests for the `ci-excluded` configuration in the `platform` infrastructure layer of the `tpi-1` cluster.
- **Functionality**:
  - **Interval**: Reconciles the manifests every 5 minutes (`5m0s`).
  - **Prune**: Ensures that resources not defined in the manifests are removed from the cluster.
  - **Source Reference**: Pulls manifests from the `flux-system` Git repository.
  - **Path**: Targets the `./infrastructure/ci-excluded/tpi-1` directory in the repository for the manifests.
  - **PostBuild Substitutions**:
    - Substitutes variables from the following secrets:
      - `cluster-infrastructure-vars` (required)
      - `dns-vars` (optional)
      - `cluster-vars` (optional)
    - These substitutions allow dynamic configuration of the manifests based on secret values.
