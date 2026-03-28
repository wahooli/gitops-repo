---
title: "livingroom-pi"
has_children: true
---

# livingroom-pi

## Overview
The livingroom-pi cluster is designed to manage and deploy infrastructure and applications using GitOps principles. It leverages Flux for continuous delivery, ensuring that the desired state of the cluster is maintained through automated synchronization with a Git repository.

## Dependency Chain
The Kustomizations are ordered and dependent on each other as follows:
1. **infrastructure-core**: The foundational layer that sets up core infrastructure components.
2. **infrastructure-platform**: Dependent on `infrastructure-core`, this layer builds upon the core to establish platform-specific configurations.
3. **infrastructure-monitoring**: Dependent on `infrastructure-platform`, this layer implements monitoring solutions for the cluster.
4. **infrastructure-logging**: Also dependent on `infrastructure-platform`, this layer sets up logging capabilities.
5. **apps**: Dependent on `infrastructure-platform`, this layer deploys applications to the cluster.

## Components
- **infrastructure-core**: `./infrastructure/core/livingroom-pi`
- **infrastructure-platform**: `./infrastructure/platform/livingroom-pi`
- **infrastructure-monitoring**: `./infrastructure/monitoring/livingroom-pi`
- **infrastructure-logging**: `./infrastructure/logging/livingroom-pi`
- **apps**: `./apps/livingroom-pi`

### Applications Deployed
- authentik
- etcd
- seaweedfs
- sources

## Variable Injection
The following Secrets are used for postBuild substitution:
- **cluster-infrastructure-vars**: Required for core infrastructure variables.
- **cluster-vars**: Optional for additional cluster variables.
- **cluster-app-vars**: Optional for application-specific variables in the apps Kustomization.
