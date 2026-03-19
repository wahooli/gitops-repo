---
title: "transmission"
parent: "Apps"
grand_parent: "nas"
---

# Transmission

## Overview

The Transmission component provides a lightweight, open-source BitTorrent client deployed in the `nas` cluster. It is configured to use WireGuard for secure networking and supports persistent storage for configuration and downloaded files. The deployment is managed via Flux GitOps using a HelmRelease.

## Helm Chart(s)

### HelmRelease: `default--transmission`
- **Chart Name**: `transmission`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `transmission`
- **Target Namespace**: `default`
- **Reconciliation Interval**: `5m`

## Resource Glossary

### Networking
- **Service**:  
  A ClusterIP service named `transmission` exposes the Transmission Web UI on port `9091` for internal cluster access.

- **HTTPRoute**:  
  Configures external DNS and routing for the Transmission Web UI. Accessible via:
  - `transmission.absolutist.it`
  - `transmission.wahoo.li`

### Storage
- **PersistentVolumeClaim**:  
  - `config-transmission`: Provides persistent storage for Transmission configuration files. Requests `1Gi` of storage with `ReadWriteOnce` access mode.
  - HostPath Volume: Mounts the downloads directory at `${transmission_downloads_host_path}` for storing downloaded files.

### Security
- **ServiceAccount**:  
  A dedicated ServiceAccount named `transmission` is created for the Deployment.

### Workload
- **Deployment**:  
  - Name: `transmission`
  - Replicas: `1`
  - Strategy: `Recreate`
  - Image: `ghcr.io/linuxserver/transmission:version-4.1.0-r0`
  - Probes: Configured for liveness, readiness, and startup checks on port `9091`.

### Configuration
- **ConfigMaps**:  
  - `transmission-env-f8md8mddkf`: Provides environment variables such as timezone (`TZ`), user/group IDs (`PUID`, `PGID`), and proxy settings (`ALL_PROXY`).
  - `transmission-values-g4k66hht55`: Contains Helm values for configuring the chart, including persistence, WireGuard settings, and DNS options.
  - `transmission-wireguard-config-b9f266689g`: Stores WireGuard configuration details, including private/public keys, DNS, and routing rules.

### Image Management
- **ImageRepository**:  
  - `transmission`: Tracks the Transmission image (`ghcr.io/linuxserver/transmission`) with an update interval of `24h`.
  - `wireguard`: Tracks the WireGuard image (`ghcr.io/linuxserver/wireguard`) with an update interval of `24h`.

- **ImagePolicy**:  
  - Policies are defined for both Transmission and WireGuard images to ensure the use of specific semantic version ranges and tag patterns.

## Configuration Highlights

- **Persistence**:  
  - Configuration data is stored in a PersistentVolumeClaim (`config-transmission`).
  - Downloaded files are stored in a host-mounted directory (`${transmission_downloads_host_path}`).

- **Networking**:  
  - The Web UI is exposed internally on port `9091` via a ClusterIP service.
  - External access is configured through HTTPRoute with DNS entries for `transmission.absolutist.it` and `transmission.wahoo.li`.

- **WireGuard Integration**:  
  - WireGuard is enabled for secure networking.
  - Configuration is sourced from the `transmission-wireguard-config-b9f266689g` ConfigMap.

- **Environment Variables**:  
  - Timezone (`TZ`): `Europe/Helsinki`
  - Proxy settings (`ALL_PROXY`): `socks5://${wireguard_interface_dns}:1080/`
  - User/Group IDs (`PUID`, `PGID`): `2004`, `2003`

## Deployment

- **Target Namespace**: `default`
- **Release Name**: `transmission`
- **Reconciliation Interval**: `5m`
- **Install/Upgrade Behavior**:  
  - Unlimited retries on install remediation (`retries: -1`).
  - HelmRelease is configured to reconcile every `5m` to ensure the deployment remains consistent with the desired state.
