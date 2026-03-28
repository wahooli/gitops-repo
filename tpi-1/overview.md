---
title: "tpi-1"
has_children: true
---

# tpi-1

## Overview
The `tpi-1` cluster is designed to manage and deploy core infrastructure, platform services, monitoring, logging, alerting, and DNS services using GitOps principles with Flux. It ensures the continuous delivery of applications and infrastructure components by leveraging Kustomizations.

## Dependency Chain
The Kustomization entries are processed in the following order, with dependencies indicated:

1. **infrastructure-core**: Base infrastructure setup.
2. **infrastructure-platform**: Builds upon the core infrastructure.
3. **infrastructure-monitoring**: Depends on the platform for monitoring services.
4. **infrastructure-logging**: Also depends on the platform for logging services.
5. **infrastructure-alerting**: Requires both monitoring and logging components.
6. **infrastructure-dns**: Depends on the platform and monitoring for DNS services.
7. **infrastructure-kube-dns**: Depends on the DNS infrastructure.
8. **apps**: Deploys applications after the platform and DNS are set up.

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

- **cluster-infrastructure-vars**: Required for core infrastructure.
- **cluster-vars**: Optional for various components.
- **dns-vars**: Required for DNS-related components.
- **cluster-app-vars**: Required for application deployment.
- **authentik-app-vars**: Optional for the authentik application.
- **wireguard-tunnel-credentials**: Optional for WireGuard configuration.
