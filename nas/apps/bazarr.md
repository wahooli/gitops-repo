---
title: "bazarr"
parent: "Apps"
grand_parent: "nas"
---

# bazarr

## Overview
Bazarr is a companion application for managing and automating the downloading of subtitles for your media library. It integrates with various media servers and allows users to configure subtitle languages and download preferences. In the cluster, it serves as a deployment that interacts with other services to provide subtitle management functionalities.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--bazarr`
  - **Chart**: bazarr
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: default
  - **Provides**: Deployment, Service, PersistentVolumeClaim, and ConfigMap for the Bazarr application.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: bazarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routing rules for HTTP traffic to the Bazarr service, allowing it to be accessed via specified hostnames.
- **Service**: Exposes the Bazarr application on port 6767 for HTTP traffic and port 9707 for metrics.

### Storage
- **PersistentVolumeClaim**: Requests persistent storage for Bazarr's configuration data, ensuring data is retained across pod restarts.

### Security
- **SecurityPolicy**: Manages external authentication for the Bazarr application, ensuring secure access to the service.

### Miscellaneous
- **ConfigMap**: Stores configuration data for Bazarr, including environment variables and application settings.

## Configuration Highlights
- **Resource Requests/Limits**: The deployment specifies resource limits for CPU (150m) and memory (60Mi).
- **Persistence**: Configures persistent storage for Bazarr's configuration with a request of 1Gi.
- **Environment Variables**: Key environment variables include `PGID`, `PUID`, and `TZ` for user and timezone configuration.
- **Service Annotations**: The service is annotated for Cilium networking with global affinity settings.

## Deployment
- **Target Namespace**: default
- **Release Name**: bazarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The deployment is set to retry indefinitely on failure.
