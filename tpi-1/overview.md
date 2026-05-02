---
title: "tpi-1"
has_children: true
---

# tpi-1

## Overview
The `tpi-1` cluster is designed to manage and deploy a variety of infrastructure and application components using GitOps principles. It leverages Flux Kustomizations to automate the deployment and management of core infrastructure, monitoring, logging, alerting, DNS, and application services.

## Dependency Chain
The Kustomization entries are processed in the following order, with dependencies indicated:

1. **infrastructure-core**: Core infrastructure components.
2. **infrastructure-platform**: Depends on `infrastructure-core`.
3. **infrastructure-monitoring**: Depends on `infrastructure-platform`.
4. **infrastructure-logging**: Depends on `infrastructure-platform`.
5. **infrastructure-alerting**: Depends on both `infrastructure-monitoring` and `infrastructure-logging`.
6. **infrastructure-dns**: Depends on `infrastructure-platform`.
7. **infrastructure-kube-dns**: Depends on `infrastructure-dns`.
8. **apps**: Depends on both `infrastructure-platform` and `infrastructure-dns`.

## Components
- **Core Infrastructure**: `./infrastructure/core/tpi-1`
- **Platform Infrastructure**: `./infrastructure/platform/tpi-1`
- **Monitoring Infrastructure**: `./infrastructure/monitoring/tpi-1`
- **Logging Infrastructure**: `./infrastructure/logging/tpi-1`
- **Alerting Infrastructure**: `./infrastructure/alerting/tpi-1`
- **DNS Infrastructure**: `./infrastructure/internal-dns/tpi-1`
- **Kube DNS Infrastructure**: `./infrastructure/kube-dns/tpi-1`
- **Applications**: `./apps/tpi-1`

## Variable Injection
The following Secrets are used for postBuild substitution:

- **cluster-infrastructure-vars**: Required
- **cluster-vars**: Optional
- **dns-vars**: Optional
- **cluster-app-vars**: Required for applications
- **authentik-app-vars**: Optional
- **wireguard-tunnel-credentials**: Optional
- **syncthing-devices**: Optional
