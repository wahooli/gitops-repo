---
title: "radarr"
parent: "Apps"
grand_parent: "nas"
---

# radarr

## Overview
Radarr is a movie collection manager for Usenet and BitTorrent users, allowing for automated downloading and organization of movies. In this deployment, Radarr is configured to run in the Kubernetes cluster named 'nas', utilizing Flux for GitOps management.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--radarr`
  - **Chart**: radarr
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: Deployment, Service, PersistentVolumeClaim, and ServiceAccount for the Radarr application.

## Dependencies
There are no explicit dependencies defined for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: radarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Two HTTPRoute resources are created to manage traffic routing for Radarr. They define the hostnames and backend services for both public and private access.
- **Service**: A ClusterIP service is created to expose Radarr on port 7878 for HTTP traffic and port 9707 for metrics.

### Storage
- **PersistentVolumeClaim**: A PVC named `config-radarr` is created to provide persistent storage for Radarr's configuration, requesting 2Gi of storage.

### Security
- **ServiceAccount**: A service account named `radarr` is created to manage permissions for the Radarr deployment.

### Workload
- **Deployment**: A deployment named `radarr` is created to manage the application pods, ensuring that one replica is always running. It includes liveness, readiness, and startup probes for health checks.

## Configuration Highlights
- **Image**: The Radarr container uses the image `ghcr.io/linuxserver/radarr:6.0.4`.
- **Resource Requests/Limits**: The Radarr container has CPU limits set to 150m and memory limits set to 60Mi.
- **Persistence**: Configuration data is stored in a persistent volume, with a request for 2Gi of storage.
- **Environment Variables**: Key environment variables include `PGID`, `PUID`, and `TZ` for user and timezone configuration.

## Deployment
- **Target Namespace**: default
- **Release Name**: radarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The HelmRelease is configured to retry indefinitely on failure.
