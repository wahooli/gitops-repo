---
title: "bazarr"
parent: "Apps"
grand_parent: "nas"
---

# bazarr

## Overview
Bazarr is a companion application for managing and downloading subtitles for your media library. It integrates with various media servers and automates the process of finding and downloading subtitles for movies and TV shows. This deployment is part of the 'nas' cluster and is managed using Flux for GitOps.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease:** default--bazarr
  - **Chart:** bazarr
  - **Version:** latest (floating: >=0.1.0-0)
  - **Target Namespace:** default
  - **Provides:** A deployment of the Bazarr application, including necessary services, persistent storage, and configuration management.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name:** bazarr
- **Repository:** wahooli (oci://ghcr.io/wahooli/charts)
- **Version:** latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute:** Defines routing rules for HTTP traffic to the Bazarr service. It specifies how requests are matched and routed based on the request path and hostname.
- **Service:** Exposes the Bazarr application internally within the cluster, allowing other services to communicate with it. It listens on port 6767 for HTTP traffic.

### Storage
- **PersistentVolumeClaim:** Requests persistent storage for Bazarr's configuration data, ensuring that data is retained across pod restarts. It requests 1Gi of storage.

### Security
- **ServiceAccount:** Provides an identity for the Bazarr application to interact with the Kubernetes API, allowing it to perform necessary operations.

### Configuration
- **ConfigMap:** Stores configuration data for Bazarr, including environment variables and application settings. It is used to manage application behavior and settings dynamically.

## Configuration Highlights
- **Resource Requests/Limits:** The deployment specifies resource limits for the Bazarr application, ensuring it does not exceed allocated resources.
- **Persistence:** The application is configured to use persistent storage for its configuration data, with a request for 1Gi of storage.
- **Environment Variables:** Key environment variables include:
  - `API_KEY_FILE`: Path for the API key file.
  - `ENABLE_ADDITIONAL_METRICS`: Enables additional metrics for monitoring.
- **Deployment Strategy:** The deployment uses a Recreate strategy, meaning existing pods are terminated before new ones are created.

## Deployment
- **Target Namespace:** default
- **Release Name:** bazarr
- **Reconciliation Interval:** 5m
- **Install/Upgrade Behavior:** The HelmRelease is set to retry indefinitely on failure, ensuring resilience during installation or upgrades.
