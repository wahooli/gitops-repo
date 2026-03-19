---
title: "plex"
parent: "Apps"
grand_parent: "nas"
---

# Plex

## Overview

The `plex` component deploys the Plex Media Server, a popular media streaming platform, in the `nas` Kubernetes cluster. This deployment is managed using Flux's GitOps methodology and leverages Helm for templating and deployment. The component includes additional configurations for metrics collection, persistent storage, and GPU acceleration.

## Helm Chart(s)

- **Chart Name**: `plex`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `plex`
- **Target Namespace**: `default`

## Resource Glossary

### Networking
- **Service**: Exposes Plex on multiple ports for HTTP, DLNA, Bonjour, and other protocols. Key ports include:
  - `32400` (HTTP)
  - `1900` (DLNA UDP)
  - `5353` (Bonjour)
  - `32469` (DLNA TCP)
  - `9594` and `9000` (Metrics)
- **Ingress**: Configured with the `nginx` ingress class and supports the following hostnames:
  - `plex.wahoo.li`
  - `plex.absolutist.it`
  - Includes annotations for SSL redirection, proxy settings, and external DNS.

### Storage
- **PersistentVolumeClaim**: 
  - `config-plex`: Allocates 60Gi of storage for Plex configuration and library data.
  - HostPath volumes for movies and TV series:
    - `/data/Movies` mapped to `${plex_movies_host_path}`
    - `/data/Series` mapped to `${plex_tv_host_path}`
  - Transcoding uses an `emptyDir` volume with a 20Gi memory limit.

### Security
- **Certificate**: Manages TLS for the Plex ingress using `letsencrypt-production` as the issuer. The certificate is valid for the configured hostnames.

### Observability
- **Metrics Exporters**:
  - `plex-media-server-exporter`: Exposes Plex metrics on port `9594`.
  - Prometheus metrics are relabeled and filtered for operational relevance.
- **ServiceMonitor**: Configures Prometheus scraping for the metrics endpoints.

### Image Management
- **ImageRepository**: Tracks the Plex image (`ghcr.io/linuxserver/plex`) with an update interval of 24 hours.
- **ImagePolicy**: Ensures the Plex image adheres to a semantic versioning policy (`x.x.x`).

### Workload
- **Deployment**: Deploys the Plex Media Server with the following notable configurations:
  - **Image**: `ghcr.io/linuxserver/plex:1.43.0`
  - **Runtime Class**: `nvidia` (for GPU acceleration)
  - **Strategy**: `Recreate` (ensures a clean restart during updates)
  - **Host Network**: Enabled for direct network access.
  - **Environment Variables**: Includes GPU-specific settings (`NVIDIA_DRIVER_CAPABILITIES`, `NVIDIA_VISIBLE_DEVICES`), user/group IDs (`PUID`, `PGID`), and timezone (`TZ`).

### Initialization
- **Init Containers**:
  - `import-configuration`: Prepares the Plex library by extracting an uploaded database archive (`/pms.tgz`) if necessary.
- **ConfigMaps**:
  - `plex-library-import-initscript`: Contains the initialization script for library import.
  - `plex-metrics-exporter-entrypoint`: Manages token generation and readiness for the metrics exporter.

## Configuration Highlights

- **Resource Requests and Limits**:
  - Metrics exporter: `100m` CPU, `100Mi` memory.
  - GPU resources are configurable but commented out in the manifests.
- **Persistence**:
  - Configuration and library data are stored in a 60Gi PVC.
  - Movies and TV series are mapped to host paths.
  - Transcoding uses an in-memory volume (`emptyDir`).
- **Metrics**:
  - Prometheus scraping is enabled with custom relabeling and filtering.
  - Two metrics endpoints are exposed on ports `9594` and `9000`.
- **Environment Variables**:
  - GPU-related: `NVIDIA_DRIVER_CAPABILITIES`, `NVIDIA_VISIBLE_DEVICES`.
  - User and group IDs: `PUID=2000`, `PGID=2000`.
  - Timezone: `TZ=Europe/Helsinki`.

## Deployment

- **Target Namespace**: `default`
- **Release Name**: `plex`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**:
  - Unlimited retries on failure.
  - 15-minute timeout for installations.

This deployment is designed for high configurability and operational observability, making it suitable for a home media server with advanced features like GPU acceleration and Prometheus metrics integration. Configuration parameters such as storage paths and environment variables can be customized using Flux variables.
