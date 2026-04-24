---
title: "tpi-1"
has_children: true
---

# tpi-1

## Overview
The `tpi-1` cluster is designed to manage and deploy a variety of infrastructure components and applications using GitOps principles. It utilizes Flux for continuous delivery, ensuring that the cluster state is always in sync with the configurations defined in the Git repository.

## Dependency Chain
The Kustomization entries are processed in the following order, with dependencies indicated:

1. **infrastructure-core**: The foundational infrastructure components.
2. **infrastructure-platform**: Depends on `infrastructure-core`.
3. **infrastructure-monitoring**: Depends on `infrastructure-platform`.
4. **infrastructure-logging**: Depends on `infrastructure-platform`.
5. **infrastructure-alerting**: Depends on both `infrastructure-monitoring` and `infrastructure-logging`.
6. **infrastructure-dns**: Depends on `infrastructure-platform`.
7. **infrastructure-kube-dns**: Depends on `infrastructure-dns`.
8. **apps**: Depends on both `infrastructure-platform` and `infrastructure-dns`.

## Components
- **infrastructure-core**: `./infrastructure/core/tpi-1`
- **infrastructure-platform**: `./infrastructure/platform/tpi-1`
- **infrastructure-monitoring**: `./infrastructure/monitoring/tpi-1`
- **infrastructure-logging**: `./infrastructure/logging/tpi-1`
- **infrastructure-alerting**: `./infrastructure/alerting/tpi-1`
- **infrastructure-dns**: `./infrastructure/internal-dns/tpi-1`
- **infrastructure-kube-dns**: `./infrastructure/kube-dns/tpi-1`
- **apps**: `./apps/tpi-1`

## Variable Injection
The following Secrets are used for postBuild substitution:

- **cluster-infrastructure-vars**: Required
- **cluster-vars**: Optional
- **dns-vars**: Optional
- **cluster-app-vars**: Required for apps
- **authentik-app-vars**: Optional for apps
- **wireguard-tunnel-credentials**: Optional for apps
- **syncthing-devices**: Optional for apps
