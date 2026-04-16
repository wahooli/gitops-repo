---
title: "jellyfin"
parent: "Apps"
grand_parent: "nas"
---

# jellyfin

## Overview
Jellyfin is an open-source media server software that allows users to manage and stream their media collections. In this deployment, Jellyfin is configured to run in a Kubernetes cluster, providing a scalable and resilient environment for media streaming.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--jellyfin`
  - **Chart**: jellyfin
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: A media server application with a web interface for managing and streaming media.

## Dependencies
This HelmRelease does not have any dependencies specified.

## Helm Chart(s)
- **Chart Name**: jellyfin
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **Service**: Exposes the Jellyfin application on ports 8096 (HTTP), 8920 (HTTPS), 1900 (UDP for service discovery), and 7359 (UDP for client discovery). It uses ClusterIP to allow internal communication within the cluster.
- **HTTPRoute**: Manages HTTP traffic routing to the Jellyfin service, allowing access via specified hostnames and applying response header modifications for caching.

### Storage
- **ConfigMap**: Stores configuration data for Jellyfin, including logging settings and environment variables. It is mounted into the Jellyfin deployment to provide necessary configuration at runtime.

### Security
- **ServiceAccount**: Provides an identity for the Jellyfin application to interact with the Kubernetes API.

### Workload
- **Deployment**: Manages the Jellyfin application pods, ensuring that the desired state (1 replica) is maintained. It includes settings for liveness, readiness, and startup probes to monitor the health of the application.

## Configuration Highlights
- **Image**: Uses the Jellyfin image version `10.11.8`.
- **Persistence**: Configures persistent storage for data, cache, and configuration files, with a request for 60Gi of storage.
- **Environment Variables**: Configured via ConfigMaps, including NVIDIA driver capabilities for GPU support.
- **Deployment Strategy**: Uses a Recreate strategy for updates.

## Deployment
- **Target Namespace**: default
- **Release Name**: jellyfin
- **Reconciliation Interval**: 5m
- **Install Behavior**: The deployment is set to retry indefinitely on failure.
