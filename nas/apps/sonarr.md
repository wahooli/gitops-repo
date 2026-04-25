---
title: "sonarr"
parent: "Apps"
grand_parent: "nas"
---

# sonarr

## Overview
Sonarr is a TV series management tool that automates the downloading, sorting, and renaming of episodes. It integrates with various download clients and provides a web interface for managing your TV shows. In this deployment, Sonarr is configured to run in the `default` namespace of the cluster `nas`.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--sonarr`
  - **Chart**: sonarr
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: Deployment, Service, PersistentVolumeClaim, and ServiceAccount for running the Sonarr application.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: sonarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Two HTTP routes are defined to expose the Sonarr service. One route is for public access (`sonarr`), and the other is for private access (`sonarr-private`), both routing traffic to the Sonarr service on different ports.

### Storage
- **PersistentVolumeClaim**: A PVC named `config-sonarr` is created to provide persistent storage for Sonarr's configuration data, requesting 2Gi of storage with ReadWriteOnce access mode.

### Security
- **ServiceAccount**: A service account named `sonarr` is created to allow the Sonarr application to interact with the Kubernetes API.

### Workload
- **Deployment**: The Sonarr application is deployed with a single replica. It uses the image `ghcr.io/linuxserver/sonarr:4.0.17` and includes a sidecar container for metrics. The deployment is configured with liveness, readiness, and startup probes to ensure the application is running correctly.

## Configuration Highlights
- **Resource Requests/Limits**: The Sonarr deployment has resource limits set for the main container (200m CPU and 60Mi memory).
- **Persistence**: The configuration is stored in a persistent volume, ensuring data is retained across pod restarts.
- **Environment Variables**: Key environment variables include `PGID`, `PUID`, and `TZ` for user and timezone settings, and `ENABLE_ADDITIONAL_METRICS` for enabling metrics collection.

## Deployment
- **Target Namespace**: default
- **Release Name**: sonarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure, ensuring that the Sonarr application remains deployed.
