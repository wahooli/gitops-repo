---
title: "nas"
has_children: true
---

# nas

## Overview
The 'nas' cluster is designed to manage and deploy a variety of applications and infrastructure components using GitOps principles. It utilizes Flux Kustomizations to automate the deployment and management of resources across multiple namespaces, ensuring a consistent and reliable environment.

## Dependency Chain
The Kustomization entries are processed in the following order, with dependencies indicating the required completion of preceding components:

1. **infrastructure-core**
2. **infrastructure-platform** (depends on infrastructure-core)
3. **infrastructure-monitoring** (depends on infrastructure-platform)
4. **infrastructure-logging** (depends on infrastructure-platform)
5. **infrastructure-alerting** (depends on infrastructure-monitoring and infrastructure-logging)
6. **infrastructure-dns** (depends on infrastructure-platform and infrastructure-monitoring)
7. **infrastructure-kube-dns** (depends on infrastructure-dns)
8. **apps** (depends on infrastructure-platform and infrastructure-dns)

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
- **cluster-app-vars**: Required (for apps)
- **wireguard-tunnel-credentials**: Optional (for apps)
