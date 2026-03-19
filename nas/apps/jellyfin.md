---
title: "jellyfin"
parent: "Apps"
grand_parent: "nas"
---

# Jellyfin

## Overview
Jellyfin is an open-source media server designed to organize, stream, and manage multimedia content such as movies, TV shows, and music. In this deployment, Jellyfin is configured to run in the `nas` cluster, providing media streaming services accessible via HTTP and HTTPS. The deployment leverages GPU acceleration through NVIDIA runtime and includes persistent storage for configuration, cache, and media libraries.

## Helm Chart(s)
### HelmRelease: `default--jellyfin`
- **Chart Name**: `jellyfin`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.1-0`)
- **Release Name**: `jellyfin`
- **Target Namespace**: `default`
- **Reconciliation Interval**: `5m`

## Resource Glossary
### Networking
- **Service**: Provides internal cluster access to Jellyfin via multiple ports:
  - `8096` (HTTP)
  - `8920` (HTTPS)
  - `1900` (Service Discovery via UDP)
  - `7359` (Client Discovery via UDP)
  - Type: `ClusterIP`
  - Annotations for Cilium global service affinity.
- **Ingress**: Configures external access to Jellyfin via the hostname `jellyfin.wahoo.li`. Includes annotations for SSL redirection, proxy settings, and external DNS configuration.
- **HTTPRoute**: Defines routing rules for Jellyfin, mapping requests to the backend service on port `8096`. Supports multiple hostnames (`jellyfin.absolutist.it` and `jellyfin.wahoo.li`).

### Storage
- **Persistent Volumes**:
  - **Configuration**: Mounted at `/config` and `/config/config/logging.json`.
  - **Cache**: Mounted at `/cache`.
  - **Movies**: HostPath-mounted at `/data/Movies` using `${jellyfin_movies_host_path}`.
  - **TV Shows**: HostPath-mounted at `/data/Series` using `${jellyfin_tv_host_path}`.
  - **Transcoding**: Memory-backed `emptyDir` mounted at `/transcode` with a size limit of `20Gi`.

### Security
- **ServiceAccount**: A dedicated service account named `jellyfin` for managing permissions.
- **Runtime**: Configured to use NVIDIA GPU acceleration (`runtimeClassName: nvidia`).

### Application Configuration
- **ConfigMaps**:
  - `jellyfin-env-b9gk6bg9gg`: Provides environment variables for NVIDIA GPU capabilities (`NVIDIA_DRIVER_CAPABILITIES` and `NVIDIA_VISIBLE_DEVICES`).
  - `jellyfin-config-m2hmfgm9c9`: Contains application-specific configuration, including logging settings.
  - `jellyfin-values-g897h75f99`: Supplies Helm values, including persistence settings, ingress configuration, and resource strategies.

### Workload
- **Deployment**:
  - **Replicas**: `1`
  - **Strategy**: `Recreate`
  - **Image**: `jellyfin/jellyfin:10.11.6`
  - **Probes**: Configured for liveness, readiness, and startup checks on `/health`.
  - **Annotations**: Velero backup annotations for persistent volumes.
  - **DNS Configuration**: Custom DNS options (`ndots: 1`, `edns0`).

### Image Management
- **ImageRepository**: Tracks the `jellyfin/jellyfin` image with an update interval of `24h`.
- **ImagePolicy**: Ensures image updates follow semantic versioning (`x.x.x`).

## Configuration Highlights
- **GPU Acceleration**: Enabled via NVIDIA runtime and environment variables.
- **Persistence**: Configured for media libraries, application cache, and configuration files.
- **Ingress**: SSL redirection and proxy settings for secure external access.
- **Resource Management**: Includes memory-backed storage for transcoding and Velero backup annotations for data volumes.
- **Image Version**: Uses `jellyfin/jellyfin:10.11.6` as specified by the ImagePolicy.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `jellyfin`
- **Reconciliation Interval**: `5m`
- **Install/Upgrade Behavior**: Unlimited retries on installation failures (`remediation.retries: -1`).
