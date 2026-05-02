---
title: "livingroom-pi"
has_children: true
---

# livingroom-pi

## Overview
The livingroom-pi cluster is designed to manage and deploy infrastructure and applications using GitOps principles. It utilizes Flux to automate the synchronization of Kubernetes resources defined in a Git repository, ensuring that the cluster state matches the desired configuration.

## Dependency Chain
The Kustomization entries are organized in a sequential order, with each entry depending on the previous one:
1. **infrastructure-core**: The foundational infrastructure components.
2. **infrastructure-platform**: Builds upon the core infrastructure.
3. **infrastructure-monitoring**: Adds monitoring capabilities, dependent on the platform.
4. **infrastructure-logging**: Implements logging features, also dependent on the platform.
5. **apps**: Deploys applications, dependent on the infrastructure platform.

## Components
- **infrastructure-core**: `./infrastructure/core/livingroom-pi`
- **infrastructure-platform**: `./infrastructure/platform/livingroom-pi`
- **infrastructure-monitoring**: `./infrastructure/monitoring/livingroom-pi`
- **infrastructure-logging**: `./infrastructure/logging/livingroom-pi`
- **apps**: `./apps/livingroom-pi`

Applications deployed include:
- authentik
- etcd
- forgejo
- seaweedfs
- sources

## Variable Injection
The following Secrets are used for postBuild substitution:
- **cluster-infrastructure-vars**: Required for all Kustomizations.
- **cluster-vars**: Optional for all Kustomizations, and also for the apps Kustomization.
