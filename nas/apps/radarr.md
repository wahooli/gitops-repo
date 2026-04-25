---
title: "radarr"
parent: "Apps"
grand_parent: "nas"
---

# radarr

## Overview
Radarr is a movie collection manager for Usenet and BitTorrent users, allowing users to automate the downloading and organization of movies. In this deployment, Radarr is integrated into the Kubernetes cluster 'nas' using Flux for GitOps, ensuring that the application is continuously deployed and managed.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--radarr`
  - **Chart**: radarr
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: A fully managed Radarr application with persistent storage and monitoring capabilities.

## Dependencies
This HelmRelease does not have any dependencies specified.

## Helm Chart(s)
- **Chart Name**: radarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routes for HTTP traffic to the Radarr service, allowing access via specified hostnames and paths. Two routes are defined:
  - `radarr`: Routes traffic to the backend service on port 9000 for API requests.
  - `radarr-private`: Routes traffic to the Radarr service on port 7878 for private access.

### Storage
- **PersistentVolumeClaim**: Requests a persistent volume for Radarr's configuration data, ensuring that settings and data are retained across pod restarts.

### Security
- **ServiceAccount**: Provides an identity for the Radarr application to interact with the Kubernetes API.

### Workload
- **Deployment**: Manages the Radarr application, ensuring that it runs with the specified configuration, including resource limits, environment variables, and health checks.

## Configuration Highlights
- **Image**: Uses `ghcr.io/linuxserver/radarr:6.1.1` for the Radarr application.
- **Resource Requests/Limits**: 
  - CPU: 150m (limit), 400m (request)
  - Memory: 60Mi (limit), 256Mi (request)
- **Persistence**: 
  - Configuration data is stored in a persistent volume with a request for 2Gi of storage.
- **Environment Variables**: Configured through a ConfigMap, including `PGID`, `PUID`, and `TZ` for timezone settings.
- **Health Checks**: Liveness, readiness, and startup probes are configured for the Radarr and its exporter.

## Deployment
- **Target Namespace**: default
- **Release Name**: radarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The deployment is set to retry indefinitely on failure, ensuring resilience during updates.
