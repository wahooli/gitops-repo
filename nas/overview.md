---
title: "nas"
has_children: true
---

# nas

## Overview
The 'nas' cluster is designed to manage and deploy a variety of infrastructure and application components using GitOps principles. It leverages Flux Kustomization to automate the deployment and management of resources across multiple namespaces, ensuring a consistent and reliable environment.

## Dependency Chain
The Kustomizations are ordered and dependent on each other as follows:
1. **infrastructure-core**: The foundational layer that sets up core infrastructure components.
2. **infrastructure-platform**: Depends on `infrastructure-core` to build upon the core infrastructure.
3. **infrastructure-monitoring**: Depends on `infrastructure-platform` to implement monitoring solutions.
4. **infrastructure-logging**: Also depends on `infrastructure-platform` to set up logging capabilities.
5. **infrastructure-alerting**: Depends on both `infrastructure-monitoring` and `infrastructure-logging` for alerting functionalities.
6. **infrastructure-dns**: Depends on `infrastructure-platform` and `infrastructure-monitoring` for DNS management.
7. **infrastructure-kube-dns**: Depends on `infrastructure-dns` to configure CoreDNS.
8. **apps**: Depends on both `infrastructure-platform` and `infrastructure-dns` to deploy various applications.

## Components
- **infrastructure-core**: `./infrastructure/core/nas`
- **infrastructure-platform**: `./infrastructure/platform/nas`
- **infrastructure-monitoring**: `./infrastructure/monitoring/nas`
- **infrastructure-logging**: `./infrastructure/logging/nas`
- **infrastructure-alerting**: `./infrastructure/alerting/nas`
- **infrastructure-dns**: `./infrastructure/internal-dns/nas`
- **infrastructure-kube-dns**: `./infrastructure/kube-dns/nas`
- **apps**: `./apps/nas`

## Variable Injection
The following Secrets/ConfigMaps are used for postBuild substitution:
- **cluster-infrastructure-vars**: Required
- **cluster-vars**: Optional
- **dns-vars**: Optional
- **cluster-app-vars**: Required for apps
- **wireguard-tunnel-credentials**: Optional for apps
- **authentik-app-vars**: Optional for apps
- **syncthing-devices**: Optional for apps
- **transmission**: Optional for apps
