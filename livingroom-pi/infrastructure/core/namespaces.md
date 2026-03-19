---
title: "namespaces"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# Namespaces

## Overview

The `namespaces` component is responsible for managing the creation and configuration of key Kubernetes namespaces within the `livingroom-pi` cluster. These namespaces are foundational to organizing workloads, services, and infrastructure components, ensuring proper isolation and management of resources.

This component is deployed using Flux's Kustomize controller and includes three namespaces: `default`, `kube-system`, and `infrastructure`. Each namespace is annotated and labeled to support specific operational and infrastructure requirements.

## Resource Glossary

### Namespaces

1. **default**
   - **Purpose**: The `default` namespace is the standard namespace for resources that do not explicitly specify a namespace. It is configured with labels and annotations to integrate with Flux's Kustomize controller.
   - **Key Annotations**:
     - `kustomize.toolkit.fluxcd.io/prune: disabled`: Prevents Flux from pruning resources in this namespace.
     - `kustomize.toolkit.fluxcd.io/ssa: merge`: Enables server-side apply for resource management.
   - **Key Labels**:
     - `internal-services: "true"`: Indicates this namespace is used for internal services.
     - `kustomize.toolkit.fluxcd.io/name: infrastructure-core`: Associates this namespace with the `infrastructure-core` Kustomize overlay.
     - `kustomize.toolkit.fluxcd.io/namespace: flux-system`: Links this namespace to the `flux-system` namespace for Flux management.

2. **kube-system**
   - **Purpose**: The `kube-system` namespace is reserved for Kubernetes system components and critical cluster services. It is configured to ensure compatibility with Flux and other infrastructure tools.
   - **Key Annotations**:
     - `kustomize.toolkit.fluxcd.io/prune: disabled`: Prevents Flux from pruning resources in this namespace.
     - `kustomize.toolkit.fluxcd.io/ssa: merge`: Enables server-side apply for resource management.
   - **Key Labels**:
     - `kustomize.toolkit.fluxcd.io/name: infrastructure-core`: Associates this namespace with the `infrastructure-core` Kustomize overlay.
     - `kustomize.toolkit.fluxcd.io/namespace: flux-system`: Links this namespace to the `flux-system` namespace for Flux management.
     - `topolvm.io/webhook: ignore`: Ensures compatibility with TopoLVM webhook configurations.

3. **infrastructure**
   - **Purpose**: The `infrastructure` namespace is dedicated to hosting infrastructure-related services and components. It is labeled to integrate with Flux and other tools.
   - **Key Labels**:
     - `internal-services: "true"`: Indicates this namespace is used for internal services.
     - `kustomize.toolkit.fluxcd.io/name: infrastructure-core`: Associates this namespace with the `infrastructure-core` Kustomize overlay.
     - `kustomize.toolkit.fluxcd.io/namespace: flux-system`: Links this namespace to the `flux-system` namespace for Flux management.
     - `topolvm.io/webhook: ignore`: Ensures compatibility with TopoLVM webhook configurations.

## Deployment

- **Target Namespaces**: 
  - `default`
  - `kube-system`
  - `infrastructure`
- **Reconciliation Interval**: Managed by Flux's Kustomize controller, which ensures the namespaces are reconciled and maintained in their desired state.
- **Install/Upgrade Behavior**: 
  - Annotations such as `kustomize.toolkit.fluxcd.io/prune: disabled` and `kustomize.toolkit.fluxcd.io/ssa: merge` ensure that resources are not pruned and are managed using server-side apply for consistency and reliability. 

This component is critical for maintaining the organizational structure and operational integrity of the `livingroom-pi` cluster.
