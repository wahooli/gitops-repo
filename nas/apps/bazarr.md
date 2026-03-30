---
title: "bazarr"
parent: "Apps"
grand_parent: "nas"
---

# bazarr

## Overview
Bazarr is a companion application for managing and downloading subtitles for media files. It integrates with various media servers and provides a web interface for users to configure subtitle preferences. In the Kubernetes cluster 'nas', Bazarr is deployed using Flux for GitOps management, ensuring that the application is consistently maintained and updated.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--bazarr`
  - **Chart**: bazarr
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: default
  - **Provides**: Deployment, Service, PersistentVolumeClaim, and ConfigMap for Bazarr.

## Dependencies
No dependencies are defined for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: bazarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routing rules for incoming HTTP requests to the Bazarr service. Two routes are configured, one for public access and another for private access.
- **Service**: Exposes the Bazarr application on port 6767 for internal communication within the cluster.

### Storage
- **PersistentVolumeClaim**: Requests persistent storage for Bazarr's configuration data, ensuring that data persists across pod restarts. It requests 1Gi of storage.

### Security
- **SecurityPolicy**: Configures external authentication for Bazarr, ensuring that requests are authenticated before reaching the application.

### Miscellaneous
- **ConfigMap**: Stores configuration data for Bazarr, including environment variables and application settings.

## Configuration Highlights
- **Resource Requests/Limits**: The deployment specifies resource limits for the Bazarr application, ensuring it does not exceed 150m CPU and 60Mi memory.
- **Persistence**: Configures persistent storage for Bazarr's configuration, with a 1Gi storage request.
- **Environment Variables**: Key environment variables include `API_KEY_FILE`, `ENABLE_ADDITIONAL_METRICS`, and `URL`, which are essential for the application's operation.
- **Service Annotations**: The service is annotated for Cilium networking, enabling local affinity.

## Deployment
- **Target Namespace**: default
- **Release Name**: bazarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The HelmRelease is configured to retry indefinitely on failure, ensuring resilience during deployment.
