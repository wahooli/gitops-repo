---
title: "radarr"
parent: "Apps"
grand_parent: "nas"
---

# radarr

## Overview
Radarr is a movie collection manager for Usenet and BitTorrent users. It automates the process of downloading and managing movies, providing a user-friendly interface for tracking and organizing your movie library. In the `nas` cluster, Radarr is deployed using Flux for GitOps, ensuring that the deployment is continuously reconciled with the desired state defined in the repository.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--radarr`
  - **Chart**: radarr
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: Deployment of the Radarr application, including necessary services and persistent storage.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: radarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routing rules for HTTP traffic. Two routes are created:
  - `radarr`: Routes traffic to the Radarr service on port 9000.
  - `radarr-private`: Routes traffic to the Radarr service on port 7878, with an external DNS annotation for accessibility.

### Storage
- **PersistentVolumeClaim**: Requests 2Gi of storage for the Radarr configuration, ensuring that the application can persist its settings and data across restarts.

### Security
- **ServiceAccount**: A dedicated service account for the Radarr application, allowing it to interact with the Kubernetes API securely.

### Workload
- **Deployment**: Manages the Radarr application, specifying a single replica with a Recreate strategy. It includes:
  - **Containers**: 
    - `radarr`: The main application container running the Radarr service.
    - `radarr-exporter`: A metrics exporter for monitoring Radarr's performance.
  - **Probes**: Liveness, readiness, and startup probes to ensure the application is running correctly.

## Configuration Highlights
- **Resource Requests/Limits**: The Radarr container has CPU limits set to 150m and memory limits to 60Mi.
- **Persistence**: Configuration is stored in a persistent volume claim with 2Gi of storage.
- **Environment Variables**: Configured via a ConfigMap, including `PGID`, `PUID`, and `TZ` for timezone settings.
- **Service Annotations**: Includes annotations for Cilium to manage service affinity.

## Deployment
- **Target Namespace**: default
- **Release Name**: radarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The deployment is set to retry indefinitely on failure, ensuring resilience during installation or upgrades.
