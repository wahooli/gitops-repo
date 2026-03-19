---
title: "nas"
has_children: true
---

# nas

## Overview
The `nas` cluster is a Kubernetes cluster managed using GitOps principles with Flux. It is designed to host and manage infrastructure components, monitoring, logging, alerting, DNS services, and various applications. This cluster is tailored for storage, media management, and related services.

## Dependency Chain
The `nas` cluster's configuration is organized into a series of Flux Kustomizations, executed in a specific order to ensure proper dependency resolution:

1. **infrastructure-core**: Deploys core infrastructure components such as `cert-manager` and `victoria-metrics-operator`.
2. **infrastructure-platform**: Builds on the core infrastructure to provide platform-level services.
3. **infrastructure-monitoring**: Adds monitoring capabilities, including VictoriaMetrics components.
4. **infrastructure-logging**: Sets up logging infrastructure using Vector and related components.
5. **infrastructure-alerting**: Configures alerting services, dependent on monitoring and logging.
6. **infrastructure-dns**: Deploys internal DNS services like `unbound` and `blocky`.
7. **infrastructure-kube-dns**: Configures Kubernetes DNS services, dependent on internal DNS.
8. **apps**: Deploys applications such as `authentik`, `plex`, `radarr`, and more, dependent on platform and DNS services.

## Components

### Infrastructure Kustomizations
1. **infrastructure-core**
   - **Source Path**: `./infrastructure/core/nas`
   - **Health Checks**:
     - `cert-manager` (Deployment, `cert-manager` namespace)
     - `victoria-metrics-operator` (Deployment, `victoria-metrics` namespace)

2. **infrastructure-platform**
   - **Source Path**: `./infrastructure/platform/nas`

3. **infrastructure-monitoring**
   - **Source Path**: `./infrastructure/monitoring/nas`
   - **Health Checks**:
     - `vmagent-nas` (Deployment, `monitoring` namespace)
     - `vmauth-global-write` (Deployment, `monitoring` namespace)
     - `vmauth-read-proxy` (Deployment, `monitoring` namespace)
     - `vminsert-long-term` (Deployment, `monitoring` namespace)
     - `vminsert-short-term-nas` (Deployment, `monitoring` namespace)
     - `vmselect-long-term` (StatefulSet, `monitoring` namespace)
     - `vmselect-short-term-nas` (StatefulSet, `monitoring` namespace)
     - `vmstorage-long-term` (StatefulSet, `monitoring` namespace)
     - `vmstorage-short-term-nas` (StatefulSet, `monitoring` namespace)

4. **infrastructure-logging**
   - **Source Path**: `./infrastructure/logging/nas`
   - **Health Checks**:
     - `vector-agent` (DaemonSet, `logging` namespace)
     - `vector-global-write` (Deployment, `logging` namespace)
     - `vector-lb-nas` (Deployment, `logging` namespace)
     - `vlsingle-long-term-nas` (Deployment, `logging` namespace)
     - `vlsingle-short-term-nas` (Deployment, `logging` namespace)
     - `vmauth-read-proxy` (Deployment, `logging` namespace)

5. **infrastructure-alerting**
   - **Source Path**: `./infrastructure/alerting/nas`
   - **Health Checks**:
     - `vmalert-vlogs-nas` (Deployment, `alerting` namespace)
     - `vmalert-vmetrics-nas` (Deployment, `alerting` namespace)
     - `vmalertmanager-nas` (StatefulSet, `alerting` namespace)

6. **infrastructure-dns**
   - **Source Path**: `./infrastructure/internal-dns/nas`
   - **Health Checks**:
     - `unbound` (Deployment, `internal-dns` namespace)
     - `blocky` (Deployment, `internal-dns` namespace)

7. **infrastructure-kube-dns**
   - **Source Path**: `./infrastructure/kube-dns/nas`
   - **Health Checks**:
     - `coredns` (Deployment, `kube-system` namespace)

### Applications
- **Kustomization Name**: `apps`
  - **Source Path**: `./apps/nas`
  - **Applications Deployed**:
    - `authentik`
    - `bazarr`
    - `crowdsec`
    - `deluge`
    - `etcd`
    - `grafana`
    - `jellyfin`
    - `jellyplex-watched`
    - `plex`
    - `prowlarr`
    - `ps3netsrv`
    - `radarr`
    - `seaweedfs`
    - `sonarr`
    - `transmission-old`
    - `transmission`

## Variable Injection
The following Secrets are used for `postBuild` substitution across the Kustomizations:

1. **cluster-infrastructure-vars** (required)
2. **cluster-vars** (optional)
3. **dns-vars** (optional, used in DNS-related Kustomizations)
4. **cluster-app-vars** (required, used in the `apps` Kustomization)
5. **wireguard-tunnel-credentials** (optional, used in the `apps` Kustomization)
