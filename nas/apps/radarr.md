---
title: "radarr"
parent: "Apps"
grand_parent: "nas"
---

# radarr

## Overview
Radarr is a movie collection manager for Usenet and BitTorrent users, allowing for the automation of downloading and managing movies. It is deployed in the 'nas' cluster and is configured to run in the default namespace.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--radarr`
  - **Chart**: radarr
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: Deployment of the Radarr application, including necessary services, persistent storage, and environment configurations.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: radarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Two HTTPRoute resources are created to manage traffic routing for Radarr. They define the rules for incoming requests and specify backend services.
  - `radarr`: Routes traffic to the Radarr service on port 7878 for API requests.
  - `radarr-private`: Routes traffic to the Radarr service on port 7878 for private access.

### Storage
- **PersistentVolumeClaim**: A PVC named `config-radarr` is created to ensure that Radarr has persistent storage for its configuration data, requesting 2Gi of storage with ReadWriteOnce access.

### Security
- **ServiceAccount**: A ServiceAccount named `radarr` is created to provide the necessary permissions for the Radarr application to interact with the Kubernetes API.

### Workload
- **Deployment**: A Deployment named `radarr` is created to manage the Radarr application pods. It specifies a single replica and uses a Recreate strategy for updates. The deployment includes:
  - **Containers**: 
    - The main Radarr container runs the image `ghcr.io/linuxserver/radarr:6.1.1`.
    - A secondary container, `radarr-exporter`, is included for metrics collection.

### Configuration
- **ConfigMap**: Two ConfigMaps are created:
  - `radarr-values-8mgh624cbm`: Contains configuration values for the Radarr deployment, including resource limits, persistence settings, and environment variables.
  - `radarr-env-gk9dgb4gfb`: Holds environment variables like PGID, PUID, and timezone settings.

## Configuration Highlights
- **Resource Requests/Limits**: The Radarr container has CPU limits set to 150m and memory limits set to 60Mi.
- **Persistence**: Configuration data is stored persistently with a PVC requesting 2Gi of storage.
- **Environment Variables**: Key environment variables include:
  - `PGID`: 2003
  - `PUID`: 2002
  - `TZ`: Europe/Helsinki
- **Service Annotations**: The main service has annotations for Cilium networking, enabling local affinity.

## Deployment
- **Target Namespace**: default
- **Release Name**: radarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The HelmRelease is configured to allow unlimited retries on installation or upgrades.
