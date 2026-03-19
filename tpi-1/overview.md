---
title: "tpi-1"
has_children: true
---

# tpi-1

## Overview
The `tpi-1` cluster is a Kubernetes environment managed using GitOps principles with Flux. It is configured to deploy and manage core infrastructure, monitoring, logging, alerting, DNS services, and various applications. This cluster is designed to provide a robust platform for running applications and services with integrated observability and operational tooling.

## Dependency Chain
The cluster's configuration is organized into a series of Flux Kustomizations, each with specific dependencies to ensure proper deployment order:

1. **infrastructure-core**: Deploys core infrastructure components such as `cert-manager` and `victoria-metrics-operator`.
2. **infrastructure-platform**: Builds upon the core infrastructure to provide platform-level services.
3. **infrastructure-monitoring**: Adds monitoring capabilities, including VictoriaMetrics components.
4. **infrastructure-logging**: Implements logging infrastructure using Vector and related components.
5. **infrastructure-alerting**: Configures alerting services, dependent on monitoring and logging.
6. **infrastructure-dns**: Sets up internal DNS services, dependent on platform and monitoring.
7. **infrastructure-kube-dns**: Configures Kubernetes DNS using CoreDNS, dependent on internal DNS.
8. **apps**: Deploys various applications, dependent on platform and DNS.

## Components
The following Kustomizations are defined for this cluster:

### Infrastructure
1. **infrastructure-core**
   - **Source Path**: `./infrastructure/core/tpi-1`
   - **Health Checks**:
     - `cert-manager` (Deployment, `cert-manager` namespace)
     - `victoria-metrics-operator` (Deployment, `victoria-metrics` namespace)

2. **infrastructure-platform**
   - **Source Path**: `./infrastructure/platform/tpi-1`

3. **infrastructure-monitoring**
   - **Source Path**: `./infrastructure/monitoring/tpi-1`
   - **Health Checks**:
     - Various VictoriaMetrics components in the `monitoring` namespace (e.g., `vmagent-tpi-1`, `vminsert-short-term-tpi-1`)

4. **infrastructure-logging**
   - **Source Path**: `./infrastructure/logging/tpi-1`
   - **Health Checks**:
     - Vector components and logging-related deployments in the `logging` namespace

5. **infrastructure-alerting**
   - **Source Path**: `./infrastructure/alerting/tpi-1`
   - **Health Checks**:
     - Alerting components such as `vmalert-vlogs-tpi-1` in the `alerting` namespace

6. **infrastructure-dns**
   - **Source Path**: `./infrastructure/internal-dns/tpi-1`
   - **Health Checks**:
     - DNS components such as `unbound` and `blocky` in the `internal-dns` namespace

7. **infrastructure-kube-dns**
   - **Source Path**: `./infrastructure/kube-dns/tpi-1`
   - **Health Checks**:
     - `coredns` (Deployment, `kube-system` namespace)

### Applications
1. **apps**
   - **Source Path**: `./apps/tpi-1`
   - **Applications Deployed**: 
     - `authentik`, `bazarr`, `crowdsec`, `etcd`, `grafana`, `jellyfin`, `mail-relay`, `ombi`, `overseerr`, `paperless-ngx`, `radarr`, `seaweedfs`, `sonarr`, `sources`, `tautulli`, `vaultwarden`

## Variable Injection
The following Secrets are used for postBuild substitution across the Kustomizations:

- **cluster-infrastructure-vars**: Required for infrastructure-related configurations.
- **cluster-vars**: Optional for additional cluster-specific configurations.
- **dns-vars**: Used for DNS-related configurations (required for `infrastructure-dns` and `infrastructure-kube-dns`).
- **cluster-app-vars**: Required for application-specific configurations.
- **authentik-app-vars**: Optional for `authentik` application configuration.
- **wireguard-tunnel-credentials**: Optional for WireGuard tunnel setup.
