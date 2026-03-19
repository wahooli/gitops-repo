---
title: "gateway-api"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# Gateway-API

## Overview
The `gateway-api` component provides the Custom Resource Definitions (CRDs) for the Gateway API, a set of resources designed to model service networking in Kubernetes. This component is deployed in the `nas` cluster and is managed using Flux. It includes both standard and experimental CRDs, enabling users to adopt stable features while optionally experimenting with new capabilities.

## Sub-components
This component consists of two sub-components, each represented by a Flux `Kustomization`:

1. **gateway-api-standard**: Deploys the standard Gateway API CRDs.
2. **gateway-api-experimental**: Deploys the experimental Gateway API CRDs. This sub-component depends on the successful deployment of `gateway-api-standard`.

## Dependencies
The `gateway-api-experimental` sub-component depends on `gateway-api-standard`. This ensures that the standard CRDs are installed before the experimental CRDs, maintaining compatibility and avoiding resource conflicts.

- **gateway-api-standard**: Provides the stable Gateway API CRDs.
- **gateway-api-experimental**: Extends the standard CRDs with experimental features for advanced use cases.

## Helm Chart(s)
This component does not use Helm charts. Instead, it is sourced directly from a Git repository containing the Gateway API CRDs.

## Resource Glossary
The `gateway-api` component creates the following Kubernetes resources:

### Networking
- **Custom Resource Definitions (CRDs)**: 
  - The `gateway-api-standard` sub-component installs the stable CRDs required for the Gateway API, such as `Gateway`, `HTTPRoute`, and `TCPRoute`.
  - The `gateway-api-experimental` sub-component installs additional experimental CRDs, such as `GRPCRoute` and other features under development.

### Flux Resources
- **GitRepository**: 
  - A `GitRepository` resource named `gateway-api` in the `flux-system` namespace is used to fetch the Gateway API CRDs from the official GitHub repository (`https://github.com/kubernetes-sigs/gateway-api.git`) at tag `v1.2.1`.
- **Kustomization**:
  - `gateway-api-standard`: Applies the standard CRDs from the `./config/crd` directory of the Git repository.
  - `gateway-api-experimental`: Applies the experimental CRDs from the `./config/crd/experimental` directory of the Git repository. This Kustomization depends on `gateway-api-standard`.

## Configuration Highlights
- **GitRepository Configuration**:
  - Repository URL: `https://github.com/kubernetes-sigs/gateway-api.git`
  - Tag: `v1.2.1`
  - Sync Interval: 48 hours
  - Ignore rules: Excludes all files except those in the `config/crd` directory.
- **Kustomization Configuration**:
  - `gateway-api-standard`:
    - Path: `./config/crd`
    - Reconciliation Interval: 24 hours
    - Prune: Disabled
  - `gateway-api-experimental`:
    - Path: `./config/crd/experimental`
    - Reconciliation Interval: 24 hours
    - Prune: Disabled
    - Dependency: `gateway-api-standard`

## Deployment
- **Target Namespace**: `flux-system`
- **Reconciliation Intervals**:
  - `GitRepository`: 48 hours
  - `gateway-api-standard`: 24 hours
  - `gateway-api-experimental`: 24 hours
- **Install/Upgrade Behavior**:
  - The `gateway-api-standard` Kustomization is applied first to ensure the stable CRDs are available.
  - The `gateway-api-experimental` Kustomization is applied only after the successful deployment of `gateway-api-standard`.
