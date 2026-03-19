---
title: "namespaces"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# Namespaces

## Overview
The `namespaces` component is responsible for managing the creation and configuration of key namespaces within the `tpi-1` cluster. These namespaces are foundational to the cluster's organization and are used to separate workloads and services based on their purpose or function. This component ensures that namespaces are consistently labeled and annotated for integration with other cluster components and tools.

## Resource Glossary
This component creates the following Kubernetes resources:

### Namespaces
1. **default**
   - **Purpose**: The `default` namespace is the standard namespace for resources that do not explicitly specify a namespace. It is configured with labels and annotations to integrate with Flux and other internal services.
   - **Key Labels**:
     - `internal-services: "true"`: Indicates that this namespace is used for internal services.
     - `kustomize.toolkit.fluxcd.io/name: infrastructure-core`: Links the namespace to the Flux Kustomization managing it.
   - **Key Annotations**:
     - `kustomize.toolkit.fluxcd.io/prune: disabled`: Prevents Flux from pruning this namespace.
     - `kustomize.toolkit.fluxcd.io/ssa: merge`: Enables server-side apply for managing this namespace.

2. **kube-system**
   - **Purpose**: The `kube-system` namespace is reserved for Kubernetes system components, such as the kubelet and control plane services. This namespace is configured with additional labels and annotations for integration with Flux and TopoLVM.
   - **Key Labels**:
     - `topolvm.io/webhook: ignore`: Ensures compatibility with TopoLVM by ignoring webhook operations in this namespace.
     - `kustomize.toolkit.fluxcd.io/name: infrastructure-core`: Links the namespace to the Flux Kustomization managing it.
   - **Key Annotations**:
     - `kustomize.toolkit.fluxcd.io/prune: disabled`: Prevents Flux from pruning this namespace.
     - `kustomize.toolkit.fluxcd.io/ssa: merge`: Enables server-side apply for managing this namespace.

3. **infrastructure**
   - **Purpose**: The `infrastructure` namespace is dedicated to hosting infrastructure-related services and components. It is labeled for internal services and integration with Flux and TopoLVM.
   - **Key Labels**:
     - `internal-services: "true"`: Indicates that this namespace is used for internal services.
     - `topolvm.io/webhook: ignore`: Ensures compatibility with TopoLVM by ignoring webhook operations in this namespace.
     - `kustomize.toolkit.fluxcd.io/name: infrastructure-core`: Links the namespace to the Flux Kustomization managing it.

## Deployment
- **Target Namespaces**: `default`, `kube-system`, `infrastructure`
- **Reconciliation Behavior**:
  - Flux annotations ensure that these namespaces are managed with server-side apply (`ssa: merge`) and are protected from pruning (`prune: disabled`).
- **Flux Kustomization**: Managed under the `infrastructure-core` Kustomization in the `flux-system` namespace.
