---
title: "namespaces"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# Namespaces

## Overview

The `namespaces` component is responsible for managing the creation and configuration of key Kubernetes namespaces within the `nas` cluster. These namespaces are foundational to organizing and isolating workloads and services in the cluster. The component ensures that namespaces are properly labeled and annotated for integration with other cluster components and tools.

## Resource Glossary

This component creates the following Kubernetes namespaces:

### 1. `default`
- **Purpose**: The default namespace for workloads and resources that do not explicitly specify a namespace.
- **Labels**:
  - `internal-services: "true"`: Indicates that this namespace is used for internal services.
  - `kustomize.toolkit.fluxcd.io/name: infrastructure-core`: Identifies the Kustomize application managing this namespace.
  - `kustomize.toolkit.fluxcd.io/namespace: flux-system`: Specifies the Flux system namespace managing this resource.
- **Annotations**:
  - `kustomize.toolkit.fluxcd.io/prune: disabled`: Prevents Flux from pruning this namespace.
  - `kustomize.toolkit.fluxcd.io/ssa: merge`: Enables server-side apply for managing this namespace.

### 2. `kube-system`
- **Purpose**: Reserved for Kubernetes system components and critical cluster services.
- **Labels**:
  - `kustomize.toolkit.fluxcd.io/name: infrastructure-core`: Identifies the Kustomize application managing this namespace.
  - `kustomize.toolkit.fluxcd.io/namespace: flux-system`: Specifies the Flux system namespace managing this resource.
  - `topolvm.io/webhook: ignore`: Indicates that this namespace should be ignored by the TopoLVM webhook.
- **Annotations**:
  - `kustomize.toolkit.fluxcd.io/prune: disabled`: Prevents Flux from pruning this namespace.
  - `kustomize.toolkit.fluxcd.io/ssa: merge`: Enables server-side apply for managing this namespace.

### 3. `infrastructure`
- **Purpose**: Dedicated namespace for infrastructure-related services and resources.
- **Labels**:
  - `internal-services: "true"`: Indicates that this namespace is used for internal services.
  - `kustomize.toolkit.fluxcd.io/name: infrastructure-core`: Identifies the Kustomize application managing this namespace.
  - `kustomize.toolkit.fluxcd.io/namespace: flux-system`: Specifies the Flux system namespace managing this resource.
  - `topolvm.io/webhook: ignore`: Indicates that this namespace should be ignored by the TopoLVM webhook.

## Configuration Highlights

- **Namespace Labels**: Each namespace is labeled to indicate its purpose and integration with other tools and components, such as Flux and TopoLVM.
- **Namespace Annotations**: Annotations are used to control Flux behavior, such as disabling pruning and enabling server-side apply.

## Deployment

- **Target Namespaces**: The `namespaces` component creates and manages the following namespaces:
  - `default`
  - `kube-system`
  - `infrastructure`
- **Reconciliation**: Managed by Flux with annotations to control pruning and server-side apply behavior.
- **Install/Upgrade Behavior**: The namespaces are configured to persist across updates and are not pruned by Flux.
