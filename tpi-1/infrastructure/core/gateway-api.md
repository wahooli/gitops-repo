---
title: "gateway-api"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# Gateway API

## Overview

The `gateway-api` component provides the Custom Resource Definitions (CRDs) necessary for implementing the Kubernetes Gateway API, a set of resources for managing networking in Kubernetes clusters. This component is deployed in the `tpi-1` cluster using Flux and is sourced from the official Gateway API GitHub repository. It includes both standard and experimental CRDs, enabling users to adopt the Gateway API incrementally.

## Sub-components

This component is managed as a multi-part deployment with the following sub-components:

1. **gateway-api-standard**: Deploys the standard Gateway API CRDs.
2. **gateway-api-experimental**: Deploys the experimental Gateway API CRDs, which depend on the standard CRDs.

## Dependencies

The `gateway-api-experimental` sub-component depends on the `gateway-api-standard` sub-component. This ensures that the standard CRDs are installed before the experimental CRDs, maintaining compatibility and proper functionality.

- **gateway-api-standard**: Provides the core Gateway API CRDs.
- **gateway-api-experimental**: Extends the Gateway API with experimental CRDs for testing and early adoption of new features.

## Helm Chart(s)

This component does not use Helm charts. Instead, it is managed via Flux Kustomizations and a GitRepository source.

## Resource Glossary

### Networking

- **Custom Resource Definitions (CRDs)**: 
  - The `gateway-api-standard` sub-component installs the standard Gateway API CRDs, such as `Gateway`, `HTTPRoute`, `TCPRoute`, and `TLSRoute`. These CRDs define the core resources for managing networking in Kubernetes clusters.
  - The `gateway-api-experimental` sub-component installs experimental CRDs, such as `GRPCRoute` and other resources that are in early development stages.

### Flux Resources

- **GitRepository**: 
  - The `gateway-api` GitRepository resource fetches the Gateway API source code from the official GitHub repository (`https://github.com/kubernetes-sigs/gateway-api.git`) at tag `v1.2.1`. It ensures that only the CRDs are included by ignoring all other files except those in the `config/crd` directory.
- **Kustomization**: 
  - `gateway-api-standard`: Applies the standard CRDs from the `config/crd` directory of the GitRepository.
  - `gateway-api-experimental`: Applies the experimental CRDs from the `config/crd/experimental` directory of the GitRepository. This Kustomization depends on the successful application of `gateway-api-standard`.

## Configuration Highlights

- The `gateway-api` GitRepository is configured to sync every 48 hours, ensuring that the latest updates to the specified tag (`v1.2.1`) are fetched.
- The `gateway-api-standard` and `gateway-api-experimental` Kustomizations are reconciled every 24 hours.
- The `prune` option is disabled for both Kustomizations, meaning resources are not automatically deleted if they are removed from the source.

## Deployment

- **Target Namespace**: `flux-system`
- **Reconciliation Intervals**:
  - `gateway-api` GitRepository: 48 hours
  - `gateway-api-standard` Kustomization: 24 hours
  - `gateway-api-experimental` Kustomization: 24 hours
- **Install/Upgrade Behavior**:
  - The `gateway-api-standard` Kustomization is applied first to ensure the standard CRDs are available.
  - The `gateway-api-experimental` Kustomization is applied only after the `gateway-api-standard` Kustomization has been successfully reconciled.
