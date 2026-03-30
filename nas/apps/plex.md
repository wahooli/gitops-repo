---
title: "plex"
parent: "Apps"
grand_parent: "nas"
---

# plex

## Overview
The `plex` component deploys a Plex Media Server in the Kubernetes cluster, allowing users to manage and stream their media collections. It utilizes a Helm chart to manage its deployment and configuration, ensuring that the application is easily updatable and maintainable.

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
- **HTTPRoute**: Manages HTTP traffic routing to the Plex service, allowing access via specified hostnames.
- **Service**: Exposes the Plex Media Server on port 32400 for HTTP traffic and port 1900 for DLNA UDP traffic.

### Storage
- **PersistentVolumeClaim**: Requests a persistent volume for storing Plex configuration and media data, with a storage request of 70Gi.

### Security
- **ServiceAccount**: Provides an identity for the Plex application to interact with the Kubernetes API.

### Configuration
- **ConfigMap**: Contains various configuration scripts and environment variables necessary for the Plex Media Server operation, including initialization scripts and NVIDIA library fixes.

## Configuration Highlights
- **Resource Requests/Limits**: The Plex Media Server is configured with CPU and memory limits of 100m and 100Mi, respectively.
- **Persistence**: The configuration is stored in a PersistentVolumeClaim with a request for 70Gi of storage.
- **Environment Variables**: Configures NVIDIA driver capabilities and timezone settings via a ConfigMap.
- **Init Containers**: Includes an init container for importing existing Plex configurations from a tarball.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `plex`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure with a timeout of 15 minutes for installation.
