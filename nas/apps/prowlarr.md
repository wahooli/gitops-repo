---
title: "prowlarr"
parent: "Apps"
grand_parent: "nas"
---

# prowlarr

## Overview
Prowlarr is a tool designed for managing and automating the downloading of media content. It acts as a companion application to various download clients and indexers, providing a unified interface for managing these services. In this deployment, Prowlarr is configured to run in the `default` namespace of the Kubernetes cluster named `nas`.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--prowlarr`
  - **Chart**: prowlarr
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: default
  - **Provides**: Deployment of the Prowlarr application, including necessary services and persistent storage.

## Helm Chart(s)
- **Chart Name**: prowlarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service**: A ClusterIP service named `prowlarr` that exposes the application on port `9696` for HTTP traffic and port `9707` for metrics. This allows other services within the cluster to communicate with Prowlarr.

### Storage
- **PersistentVolumeClaim**: A PVC named `config-prowlarr` that requests `1Gi` of storage. This is used to persist configuration data for Prowlarr, ensuring that settings are retained across pod restarts.

### Security
- **ServiceAccount**: A service account named `prowlarr` that grants permissions to the Prowlarr deployment, allowing it to interact with the Kubernetes API.

### Workload
- **Deployment**: A deployment named `prowlarr` that manages the Prowlarr application. It is configured to run a single replica and uses a `Recreate` strategy for updates. The deployment includes two containers: 
  - The main Prowlarr application container, which listens on port `9696`.
  - An exporter container for metrics, which listens on port `9707`.

## Configuration Highlights
- **Image**: The Prowlarr application uses the image `ghcr.io/linuxserver/prowlarr:2.3.0`.
- **Resource Requests/Limits**: Resource requests and limits are defined for the metrics container, with CPU limits set to `100m` and memory limits to `60Mi`.
- **Persistence**: The configuration is stored in a persistent volume, ensuring data is retained across restarts.
- **Environment Variables**: Key environment variables include `PGID`, `PUID`, and `TZ` for user and timezone settings.

## Deployment
- **Target Namespace**: default
- **Release Name**: prowlarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The deployment is set to retry indefinitely on failure, ensuring resilience during installation or upgrades.
