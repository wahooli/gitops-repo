---
title: "platform resources"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

## Overview

The `ci-excluded` resource in the `platform` infrastructure layer for the `nas` cluster is a standalone Kubernetes resource managed by Flux. It is a `Kustomization` resource that defines how a specific set of Kubernetes manifests should be applied to the cluster. This resource ensures that the manifests located in the `./infrastructure/ci-excluded/nas` directory of the Git repository are synchronized with the cluster. It uses Flux's GitOps methodology to automate the deployment and reconciliation of these manifests.

## Resource Glossary

### Kustomization: `ci-excluded`
- **Kind**: `Kustomization`
- **Name**: `ci-excluded`
- **Namespace**: `flux-system`
- **Purpose**: This resource is responsible for managing the deployment of Kubernetes manifests located in the `./infrastructure/ci-excluded/nas` directory of the Git repository. It ensures that the cluster state matches the desired state defined in the repository.
- **Details**:
  - **Interval**: The resource checks for updates in the Git repository every 5 minutes (`5m0s`).
  - **Prune**: Enabled, which means that any resources in the cluster that are no longer defined in the repository will be deleted.
  - **Source Reference**: The manifests are sourced from the `flux-system` `GitRepository` resource.
  - **Path**: The specific path in the Git repository is `./infrastructure/ci-excluded/nas`.
  - **PostBuild Substitutions**: 
    - Variables are substituted using values from two Secrets:
      - `cluster-infrastructure-vars` (required)
      - `dns-vars` (required)
    - These substitutions allow for dynamic configuration of the manifests at deploy time.
