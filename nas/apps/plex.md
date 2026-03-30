---
title: "plex"
parent: "Apps"
grand_parent: "nas"
---

# plex

## Overview
The `plex` component deploys a Plex Media Server in the Kubernetes cluster, enabling users to stream media content. This deployment includes necessary configurations for metrics, environment variables, and persistent storage for media files and server configurations.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--plex`
  - **Chart**: `plex`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `default`
  - **Provides**: Deployment of Plex Media Server with associated configurations and services.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `plex`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service**: Exposes the Plex Media Server on port `32400` for HTTP traffic and `1900` for DLNA UDP traffic, allowing clients to connect and stream media.
- **HTTPRoute**: Configures routing for the Plex service, enabling access via specified hostnames.

### Storage
- **PersistentVolumeClaim**: Requests a `70Gi` storage volume for storing Plex configurations and media library data, ensuring data persistence across pod restarts.

### Security
- **ServiceAccount**: Provides a service account for the Plex deployment, allowing it to interact with the Kubernetes API.

### Configuration
- **ConfigMap**: Contains various configuration scripts and environment variables necessary for initializing and running the Plex Media Server, including:
  - `import-config.sh`: Script for importing existing Plex configurations.
  - `fix-nvidia-libs.sh`: Script to create symlinks for NVIDIA libraries required by the Plex transcoder.

## Configuration Highlights
- **Resource Requests/Limits**: The deployment specifies resource limits for CPU and memory for containers, ensuring efficient resource usage.
- **Persistence**: Configurations for persistent storage are set up to ensure that media libraries and server settings are retained.
- **Environment Variables**: Key environment variables such as `PGID`, `PUID`, and `TZ` are configured to manage user permissions and timezone settings.
- **Metrics**: Metrics collection is enabled for monitoring the Plex server's performance.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `plex`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The HelmRelease is configured with a timeout of 15 minutes for installation and allows for unlimited retries on failure.
