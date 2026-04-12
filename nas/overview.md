---
title: "nas"
has_children: true
---

# nas

## Overview
The 'nas' cluster is designed to manage infrastructure and applications using GitOps principles with Flux. It encompasses core infrastructure components, monitoring, logging, alerting, DNS management, and application deployments.

## Dependency Chain
The Kustomizations are ordered and dependent as follows:
1. **infrastructure-core**: The foundational infrastructure setup.
2. **infrastructure-platform**: Depends on `infrastructure-core`.
3. **infrastructure-monitoring**: Depends on `infrastructure-platform`.
4. **infrastructure-logging**: Depends on `infrastructure-platform`.
5. **infrastructure-alerting**: Depends on both `infrastructure-monitoring` and `infrastructure-logging`.
6. **infrastructure-dns**: Depends on `infrastructure-platform` and `infrastructure-monitoring`.
7. **infrastructure-kube-dns**: Depends on `infrastructure-dns`.
8. **apps**: Depends on both `infrastructure-platform` and `infrastructure-dns`.

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
The following Secrets are used for postBuild substitution:
- **cluster-infrastructure-vars**: Required
- **cluster-vars**: Optional
- **dns-vars**: Optional
- **cluster-app-vars**: Required for apps
- **wireguard-tunnel-credentials**: Optional for apps
- **authentik-app-vars**: Optional for apps
- **syncthing-devices**: Optional for apps
- **transmission**: Optional for apps
