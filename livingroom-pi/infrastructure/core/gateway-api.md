---
title: "gateway-api"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# Gateway API

## Overview

The `gateway-api` component provides the Custom Resource Definitions (CRDs) necessary to enable the Gateway API in the Kubernetes cluster. The Gateway API is a set of resources for configuring networking in Kubernetes, offering more flexibility and extensibility compared to the traditional Ingress API. This component is deployed using Flux and is sourced from the official Gateway API GitHub repository.

This deployment includes two Kustomizations: one for the standard Gateway API CRDs and another for experimental CRDs. The experimental CRDs depend on the standard CRDs being deployed first.

## Sub-components

This component consists of the following sub-components:

1. **gateway-api-standard**: Deploys the standard Gateway API CRDs.
2. **gateway-api-experimental**: Deploys the experimental Gateway API CRDs. This sub-component depends on the successful deployment of `gateway-api-standard`.

## Dependencies

The `gateway-api-experimental` Kustomization has a dependency on the `gateway-api-standard` Kustomization. This ensures that the standard Gateway API CRDs are deployed before the experimental CRDs.

- **gateway-api-standard**: Provides the core CRDs for the Gateway API.
- **gateway-api-experimental**: Extends the Gateway API with experimental CRDs for advanced use cases.

## Helm Chart(s)

This component does not use Helm charts. Instead, it is managed through Flux Kustomizations and a GitRepository source.

## Resource Glossary

### Networking

- **Custom Resource Definitions (CRDs)**: The component installs CRDs that define the Gateway API resources. These resources include `GatewayClass`, `Gateway`, `HTTPRoute`, `TCPRoute`, `TLSRoute`, and others. These CRDs enable users to define and manage advanced networking configurations in Kubernetes.

### Flux Resources

- **GitRepository**: 
  - **Name**: `gateway-api`
  - **Namespace**: `flux-system`
  - **Purpose**: Points to the official Gateway API GitHub repository (`https://github.com/kubernetes-sigs/gateway-api.git`) and fetches the CRDs from the `v1.2.1` tag.
  - **Sync Interval**: 48 hours
  - **Ignore Rules**: Excludes all files except those in the `config/crd` directory.

- **Kustomization**:
  - **Name**: `gateway-api-standard`
    - **Namespace**: `flux-system`
    - **Purpose**: Deploys the standard Gateway API CRDs from the `./config/crd` directory in the Git repository.
    - **Sync Interval**: 24 hours
    - **Prune**: Disabled
  - **Name**: `gateway-api-experimental`
    - **Namespace**: `flux-system`
    - **Purpose**: Deploys the experimental Gateway API CRDs from the `./config/crd/experimental` directory in the Git repository.
    - **Sync Interval**: 24 hours
    - **Prune**: Disabled
    - **Depends On**: `gateway-api-standard`

## Configuration Highlights

- **GitRepository Source**:
  - URL: `https://github.com/kubernetes-sigs/gateway-api.git`
  - Tag: `v1.2.1`
  - Sync Interval: 48 hours
  - Ignore rules exclude all files except CRDs.

- **Kustomizations**:
  - `gateway-api-standard` deploys the standard CRDs with a 24-hour reconciliation interval.
  - `gateway-api-experimental` deploys experimental CRDs with a 24-hour reconciliation interval and depends on `gateway-api-standard`.

## Deployment

- **Target Namespace**: `flux-system`
- **Reconciliation Intervals**:
  - `GitRepository`: 48 hours
  - `gateway-api-standard`: 24 hours
  - `gateway-api-experimental`: 24 hours
- **Install/Upgrade Behavior**:
  - The `gateway-api-standard` Kustomization is deployed first to ensure the core CRDs are available.
  - The `gateway-api-experimental` Kustomization is deployed afterward, as it depends on the standard CRDs.
