---
title: "plex"
parent: "Apps"
grand_parent: "nas"
---

# plex

## Overview
The `plex` component deploys the Plex Media Server in the Kubernetes cluster, allowing users to manage and stream their media content. It utilizes a Helm chart to facilitate deployment and management, ensuring that the server is configured correctly and can scale as needed.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--plex`
  - **Chart**: `plex`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `default`
  - **Provides**: Deploys the Plex Media Server along with necessary configurations and resources.

## Dependencies
There are no explicit dependencies defined for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `plex`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Manages HTTP traffic routing to the Plex service, allowing access via defined hostnames and paths.
- **Service**: Exposes the Plex Media Server on port 32400 for HTTP traffic and port 1900 for DLNA UDP traffic.

### Storage
- **PersistentVolumeClaim**: Requests a persistent volume for storing Plex configuration and media data, ensuring data persistence across pod restarts.

### Security
- **ServiceAccount**: Provides an identity for the Plex application to interact with the Kubernetes API.

### Configuration
- **ConfigMap**: Contains various scripts and configuration files necessary for initializing the Plex Media Server and handling NVIDIA library fixes.

## Configuration Highlights
- **Resource Requests/Limits**: The Plex Media Server is configured with CPU limits of 100m and memory limits of 100Mi.
- **Persistence**: A PersistentVolumeClaim is created to ensure that the Plex configuration and media files are stored persistently with a request for 70Gi of storage.
- **Environment Variables**: Configured through ConfigMaps, including settings for NVIDIA drivers and timezone.
- **Init Containers**: Used to import existing Plex configurations if available.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `plex`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The HelmRelease is configured to retry indefinitely on failure with a timeout of 15 minutes for installation.
