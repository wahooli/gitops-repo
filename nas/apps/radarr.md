---
title: "radarr"
parent: "Apps"
grand_parent: "nas"
---

# radarr

## Overview
Radarr is a movie collection manager for Usenet and BitTorrent users, allowing for easy management and automation of movie downloads. In the `nas` cluster, it is deployed using Flux CD to ensure continuous delivery and management of its resources.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--radarr`
  - **Chart**: `radarr`
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: `default`
  - **Provides**: Deployment of Radarr application along with necessary Kubernetes resources.

## Dependencies
There are no explicit dependencies defined for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `radarr`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Two HTTP routes are created to manage traffic to Radarr:
  - `radarr`: Routes traffic to the service on port 9000.
  - `radarr-private`: Routes traffic to the Radarr service on port 7878, with annotations for external DNS.

### Storage
- **PersistentVolumeClaim**: A PVC named `config-radarr` is created to provide 2Gi of storage for Radarr's configuration data, ensuring data persistence across pod restarts.

### Security
- **ServiceAccount**: A service account named `radarr` is created, allowing the Radarr application to interact with the Kubernetes API securely.

### Workload
- **Deployment**: The Radarr application is deployed with a single replica. It includes:
  - **Containers**: 
    - `radarr`: Main application container running the Radarr service.
    - `radarr-exporter`: A metrics exporter for monitoring.
  - **Probes**: Liveness, readiness, and startup probes are configured for both containers to ensure they are running correctly.

### Miscellaneous
- **ConfigMap**: Two ConfigMaps are created:
  - `radarr-values-k5927dkmc7`: Contains configuration values for the Radarr deployment, including image tag, resource limits, and persistence settings.
  - `radarr-env-gk9dgb4gfb`: Holds environment variables such as `PGID`, `PUID`, and `TZ` for the Radarr application.

## Configuration Highlights
- **Resource Requests/Limits**: The Radarr container has CPU limits set to 150m and memory limits to 60Mi.
- **Persistence**: Configuration and data persistence is enabled with a PVC for configuration and a host path for data.
- **Environment Variables**: Key environment variables include `PGID`, `PUID`, and `TZ` for user and timezone settings.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `radarr`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The HelmRelease is configured for automatic remediation with unlimited retries.
