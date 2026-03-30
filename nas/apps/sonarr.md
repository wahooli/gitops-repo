---
title: "sonarr"
parent: "Apps"
grand_parent: "nas"
---

# sonarr

## Overview
Sonarr is a TV series management tool that automates the downloading, sorting, and renaming of episodes. It integrates with various download clients and provides a web interface for managing your TV shows. In this deployment, Sonarr is configured to run in the `default` namespace of the Kubernetes cluster `nas`.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--sonarr`
  - **Chart**: sonarr
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: Deployment, Service, PersistentVolumeClaim, and ServiceAccount for the Sonarr application.

## Helm Chart(s)
- **Chart Name**: sonarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routes for HTTP traffic to Sonarr, allowing access via specified hostnames. Two routes are created:
  - `sonarr`: Routes traffic to the Sonarr service on port 9000.
  - `sonarr-private`: Routes traffic to the Sonarr service on port 8989, with external DNS annotations.

### Storage
- **PersistentVolumeClaim**: Requests 2Gi of storage for Sonarr's configuration data, ensuring that data persists across pod restarts.

### Security
- **ServiceAccount**: Provides an identity for the Sonarr application to interact with the Kubernetes API.

### Workload
- **Deployment**: Manages the Sonarr application, ensuring that it runs with one replica. It includes:
  - Container for Sonarr using the image `ghcr.io/linuxserver/sonarr:4.0.16`.
  - Container for Sonarr exporter for additional metrics.
  - Probes for liveness, readiness, and startup checks to ensure the application is running correctly.

## Configuration Highlights
- **Resource Requests/Limits**: The Sonarr container has resource limits set for CPU (200m) and memory (60Mi).
- **Persistence**: Configuration data is stored in a PersistentVolumeClaim with 2Gi of storage.
- **Environment Variables**: Key environment variables include:
  - `PGID`: 2003
  - `PUID`: 2001
  - `TZ`: Europe/Helsinki
- **Service Annotations**: The main service is annotated for Cilium networking with global affinity.

## Deployment
- **Target Namespace**: default
- **Release Name**: sonarr
- **Reconciliation Interval**: 5m
- **Install Behavior**: The HelmRelease is configured to retry indefinitely on failure.
