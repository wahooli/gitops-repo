---
title: "sonarr"
parent: "Apps"
grand_parent: "nas"
---

# sonarr

## Overview
Sonarr is a TV series management tool that automates the downloading, sorting, and renaming of TV shows. It integrates with various download clients and provides a web interface for managing your media library. In this deployment, Sonarr is configured to run in the `default` namespace of the Kubernetes cluster named `nas`.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--sonarr`
  - **Chart**: sonarr
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: Deployment, Service, PersistentVolumeClaim, and ServiceAccount for running the Sonarr application.

## Dependencies
There are no dependencies specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: sonarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routing rules for accessing the Sonarr service. Two routes are created:
  - `sonarr`: Routes traffic to the Sonarr service on port 9000.
  - `sonarr-private`: Routes traffic to the Sonarr service on port 8989 for private access.

### Storage
- **PersistentVolumeClaim**: `config-sonarr`
  - Requests 2Gi of storage for Sonarr's configuration data, ensuring that the data persists across pod restarts.

### Security
- **ServiceAccount**: `sonarr`
  - Provides an identity for the Sonarr application to interact with the Kubernetes API.

### Workload
- **Deployment**: `sonarr`
  - Manages the Sonarr application pods, ensuring that one instance is always running. It includes:
    - **Containers**: 
      - `sonarr`: The main application container running the Sonarr service.
      - `sonarr-exporter`: A metrics exporter for monitoring Sonarr's performance.
    - **Probes**: Liveness, readiness, and startup probes to ensure the application is healthy and ready to serve traffic.

### Services
- **Service**: `sonarr`
  - Exposes the Sonarr application on port 8989 for HTTP traffic and port 9707 for metrics.

## Configuration Highlights
- **Resource Requests/Limits**: 
  - CPU limit: 200m
  - Memory limit: 60Mi
- **Persistence**: 
  - Configuration data is stored in a PersistentVolumeClaim with a request for 2Gi of storage.
- **Environment Variables**: 
  - `PGID`: 2003
  - `PUID`: 2001
  - `TZ`: Europe/Helsinki
- **Service Annotations**: 
  - `service.cilium.io/global`: "true"
  - `service.cilium.io/affinity`: "local"
- **Metrics**: 
  - Metrics collection is enabled with additional environment variables for the metrics exporter.

## Deployment
- **Target Namespace**: default
- **Release Name**: sonarr
- **Reconciliation Interval**: 5m
- **Install Behavior**: The HelmRelease is set to retry indefinitely on failure.
