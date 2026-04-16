---
title: "plex"
parent: "Apps"
grand_parent: "nas"
---

# plex

## Overview
The `plex` component deploys the Plex Media Server in the Kubernetes cluster, enabling users to stream media content. It leverages a Helm chart to manage its deployment and configuration, ensuring that the application is easily maintainable and scalable.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--plex`
  - **Chart**: `plex`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `default`
  - **Provides**: Deployment of the Plex Media Server along with necessary configurations and resources.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `plex`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Manages routing for the Plex service, allowing access via specified hostnames. It directs traffic to the Plex service on port 32400.

### Storage
- **PersistentVolumeClaim**: Requests 70Gi of storage for the Plex configuration, ensuring that media library data persists across pod restarts.

### Security
- **ServiceAccount**: Provides an identity for the Plex application to interact with the Kubernetes API.

### Application Workload
- **Deployment**: Manages the Plex Media Server application, ensuring it runs with the specified configuration, including resource limits and environment variables.
- **ConfigMap**: Contains scripts and configuration data for initializing the Plex server and fixing NVIDIA library paths.

## Configuration Highlights
- **Resource Requests/Limits**: The Plex deployment requests 100m CPU and 100Mi memory.
- **Persistence**: A PersistentVolumeClaim is created to ensure that the Plex configuration is stored persistently.
- **Environment Variables**: Configured through ConfigMaps, including settings for NVIDIA drivers and timezone.
- **Custom Scripts**: Includes initialization scripts for importing existing media libraries and fixing NVIDIA library paths.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `plex`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure, with a timeout of 15 minutes for installations.
