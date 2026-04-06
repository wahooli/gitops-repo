---
title: "livingroom-pi"
has_children: true
---

# livingroom-pi

## Overview
The livingroom-pi cluster is designed to manage and deploy various infrastructure and application components using GitOps principles. It leverages Flux Kustomizations to automate the deployment and management of resources across different namespaces.

## Dependency Chain
The Kustomization entries are ordered and dependent on one another as follows:
1. **infrastructure-core**: The foundational layer that sets up core infrastructure components.
2. **infrastructure-platform**: Depends on `infrastructure-core` and builds upon it to establish platform-level resources.
3. **infrastructure-monitoring**: Depends on `infrastructure-platform` and focuses on monitoring solutions.
4. **infrastructure-logging**: Also depends on `infrastructure-platform`, providing logging capabilities.
5. **apps**: Depends on `infrastructure-platform` and deploys various applications.

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
- **cluster-vars**: Optional for all Kustomizations.
- **cluster-app-vars**: Optional for the `apps` Kustomization.
