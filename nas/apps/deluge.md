---
title: "deluge"
parent: "Apps"
grand_parent: "nas"
---

# Deluge

## Overview
Deluge is a lightweight, open-source BitTorrent client deployed in the `nas` cluster. This component provides torrent downloading capabilities and is configured to run as a single-instance deployment. It includes persistent storage for configuration and downloads, and exposes a web-based user interface for management.

## Helm Chart(s)
- **Chart Name**: `deluge`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)

## Resource Glossary

### Networking
- **Service**: Exposes the Deluge application internally within the cluster on ports:
  - `8112` (Web UI)
  - `58846` (Client)
  The service is of type `ClusterIP` and includes global annotations for Cilium.

- **HTTPRoute**: Configures external access to the Deluge Web UI via the following hostnames:
  - `deluge.absolutist.it`
  - `deluge.wahoo.li`
  The route is linked to the `internal-gw` Gateway in the `infrastructure` namespace and forwards traffic to port `8112`.

### Storage
- **PersistentVolumeClaim**: 
  - **Name**: `config-deluge`
  - **Purpose**: Stores Deluge configuration data persistently.
  - **Size**: 1Gi
  - **Access Mode**: `ReadWriteOnce`

- **HostPath Volume**:
  - **Path**: `${deluge_downloads_host_path}`
  - **Purpose**: Stores downloaded files directly on the host filesystem.
  - **Type**: `Directory`

### Workload
- **Deployment**:
  - **Name**: `deluge`
  - **Replicas**: 1
  - **Strategy**: `Recreate`
  - **Host Networking**: Enabled for direct access to network interfaces.
  - **Probes**:
    - Liveness and readiness probes check the health of the Web UI on port `8112`.
    - Startup probe ensures the container initializes correctly before marking it ready.
  - **Resource Requests**:
    - CPU: `300m`
    - Memory: `512Mi`
  - **Resource Limits**:
    - CPU: `1000m`
    - Memory: `1536Mi`

- **ServiceAccount**:
  - **Name**: `deluge`
  - Used to manage permissions for the Deluge deployment.

### Configuration
- **ConfigMaps**:
  - **deluge-env-7774k8b7bd**: Provides environment variables for the deployment, including:
    - `PGID`: `2003`
    - `PUID`: `2005`
    - `TZ`: `Europe/Helsinki`
  - **deluge-values-k5c794bdf6**: Contains Helm values for the deployment, such as image tag, DNS configuration, and persistence settings.

### Image Management
- **ImageRepository**:
  - **Name**: `deluge`
  - **Image**: `ghcr.io/linuxserver/deluge`
  - **Update Interval**: 24h

- **ImagePolicy**:
  - **Name**: `deluge`
  - **Policy**: Tracks updates using semantic versioning (`x.x.x`).

## Configuration Highlights
- **Image**: `ghcr.io/linuxserver/deluge:2.2.0`
- **Persistence**:
  - Configuration data is stored in a PersistentVolumeClaim.
  - Downloads are stored on the host filesystem at `${deluge_downloads_host_path}`.
- **Networking**:
  - Host networking is enabled for direct access to network interfaces.
  - Service exposes Web UI on port `8112` and client connections on port `58846`.
- **Probes**:
  - Liveness and readiness probes ensure the Web UI is operational.
  - Startup probe ensures the container initializes correctly.
- **Resource Management**:
  - Requests: CPU `300m`, Memory `512Mi`
  - Limits: CPU `1000m`, Memory `1536Mi`

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `deluge`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: Unlimited retries on failure (`retries: -1`).

## Notes
- The deployment uses Flux variables for dynamic configuration:
  - `${deluge_downloads_host_path}`: Host path for downloads.
  - `${domain_absolutist_it}` and `${domain_wahoo_li}`: Domains for external access.
- Backups are enabled for the configuration volume via Velero annotations.
