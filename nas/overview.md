---
title: "nas"
has_children: true
---

# nas

## Overview
The 'nas' cluster is designed to manage and deploy a variety of infrastructure and application components using GitOps principles. It utilizes Flux Kustomization to automate the deployment and management of core infrastructure, monitoring, logging, alerting, DNS, and applications.

## Dependency Chain
The Kustomization entries are organized in a sequential order, where each entry may depend on the successful deployment of previous entries. The order is as follows:

1. **infrastructure-core**: The foundational infrastructure components.
2. **infrastructure-platform**: Builds upon the core infrastructure.
3. **infrastructure-monitoring**: Depends on the platform for monitoring solutions.
4. **infrastructure-logging**: Also depends on the platform for logging solutions.
5. **infrastructure-alerting**: Requires both monitoring and logging to set up alerting mechanisms.
6. **infrastructure-dns**: Depends on the platform for DNS services.
7. **infrastructure-kube-dns**: Builds on the DNS infrastructure.
8. **apps**: Deploys applications that rely on the infrastructure components.

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

- **cluster-infrastructure-vars**: Required for core infrastructure.
- **cluster-vars**: Optional for various components.
- **dns-vars**: Required for DNS-related components.
- **cluster-app-vars**: Required for application deployments.
- **wireguard-tunnel-credentials**: Optional for application deployments.
- **authentik-app-vars**: Optional for application deployments.
- **syncthing-devices**: Optional for application deployments.
