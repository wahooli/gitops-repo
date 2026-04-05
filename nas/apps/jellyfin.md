---
title: "jellyfin"
parent: "Apps"
grand_parent: "nas"
---

# jellyfin

## Overview
Jellyfin is an open-source media server software that allows users to organize, manage, and stream their media collections. In this Kubernetes cluster, it serves as a media streaming solution, providing access to movies, TV shows, and other media content.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--jellyfin`
  - **Chart**: jellyfin
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: Media server deployment with necessary configurations and resources.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: jellyfin
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **Service**: Exposes the Jellyfin application on multiple ports (8096 for HTTP, 8920 for HTTPS, 1900 for service discovery, and 7359 for client discovery) within the cluster, allowing other services and users to access it.
- **HTTPRoute**: Manages incoming HTTP traffic, routing requests to the Jellyfin service based on specified hostnames.

### Storage
- **ConfigMap**: Stores configuration data for Jellyfin, including logging settings and environment variables. It is mounted into the Jellyfin deployment to provide necessary configurations at runtime.

### Security
- **ServiceAccount**: Provides an identity for the Jellyfin application to interact with the Kubernetes API.

### Workload
- **Deployment**: Manages the lifecycle of the Jellyfin application, ensuring that the specified number of replicas (1) is running. It includes settings for resource management, liveness/readiness probes, and container specifications.

## Configuration Highlights
- **Image**: Uses the Jellyfin image version `10.11.7`.
- **Persistence**: Configures persistent storage for data, including movies and TV shows, with a request for 60Gi of storage.
- **Environment Variables**: Configured through a ConfigMap to set up necessary environment settings for Jellyfin.
- **Resource Requests/Limits**: Not explicitly defined in the manifests, but can be configured through the Helm values.

## Deployment
- **Target Namespace**: default
- **Release Name**: jellyfin
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure, ensuring resilience during installation or upgrades.
