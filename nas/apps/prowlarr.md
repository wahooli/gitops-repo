---
title: "prowlarr"
parent: "Apps"
grand_parent: "nas"
---

# prowlarr

## Overview
Prowlarr is a tool designed to manage and automate the downloading of content from various indexers. It acts as a companion to other applications like Sonarr and Radarr, providing a unified interface for managing indexers and their respective downloads. This deployment is part of the 'nas' cluster and is configured to run in the default namespace.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--prowlarr`
  - **Chart**: `prowlarr`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: default
  - **Provides**: A deployment of the Prowlarr application, including necessary services, persistent storage, and configuration.

## Helm Chart(s)
- **Chart Name**: `prowlarr`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service**: A ClusterIP service named `prowlarr` that exposes the application on port 9696 for HTTP traffic and port 9707 for metrics.
- **HTTPRoute**: Routes HTTP traffic to the Prowlarr service, allowing access via the hostname `prowlarr.${domain_absolutist_it:=absolutist.it}`.

### Storage
- **PersistentVolumeClaim**: A PVC named `config-prowlarr` that requests 1Gi of storage for the application's configuration data, ensuring data persistence across pod restarts.

### Security
- **ServiceAccount**: A service account named `prowlarr` that allows the application to interact with the Kubernetes API.

### Workload
- **Deployment**: A deployment named `prowlarr` that manages the application's pods, ensuring that one replica is always running. It includes liveness, readiness, and startup probes to monitor the health of the application.

## Configuration Highlights
- **Image**: The application runs on `ghcr.io/linuxserver/prowlarr:2.3.0`.
- **Resource Requests/Limits**: Resource requests are defined for the metrics container, with limits set to 100m CPU and 60Mi memory.
- **Persistence**: Configuration data is stored in a persistent volume, ensuring it is retained across pod restarts.
- **Environment Variables**: Configurable parameters include `PGID`, `PUID`, and `TZ` for user and timezone settings.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `prowlarr`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The deployment is set to automatically retry on failure, with no limit on retries.
