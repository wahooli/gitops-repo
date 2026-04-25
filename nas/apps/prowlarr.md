---
title: "prowlarr"
parent: "Apps"
grand_parent: "nas"
---

# prowlarr

## Overview
Prowlarr is a tool that acts as an indexer manager for various media downloaders. It integrates with other applications to automate the process of finding and downloading content. In this deployment, Prowlarr is set up to run in the Kubernetes cluster named 'nas', providing a centralized service for managing indexers.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--prowlarr`
  - **Chart**: prowlarr
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: default
  - **Provides**: A complete Prowlarr application setup, including a Deployment, Service, and PersistentVolumeClaim.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: prowlarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service**: Exposes the Prowlarr application on port 9696 for HTTP traffic and port 9707 for metrics. It uses ClusterIP to allow internal communication within the cluster.
- **HTTPRoute**: Routes external traffic to the Prowlarr service, allowing access via the hostname `prowlarr.${domain_absolutist_it:=absolutist.it}`.

### Storage
- **PersistentVolumeClaim**: Requests 1Gi of storage for Prowlarr's configuration data, ensuring that the data persists across pod restarts.

### Security
- **ServiceAccount**: Provides an identity for the Prowlarr application to interact with the Kubernetes API.

### Workload
- **Deployment**: Manages the Prowlarr application, ensuring that one replica is running. It includes health checks (liveness, readiness, and startup probes) to monitor the application's status.

## Configuration Highlights
- **Image**: The Prowlarr container uses the image `ghcr.io/linuxserver/prowlarr:2.3.5`.
- **Resource Requests/Limits**: The deployment is configured with resource requests and limits for the metrics container, ensuring it has sufficient resources to operate.
- **Persistence**: Configuration data is stored in a persistent volume, ensuring data durability.
- **Environment Variables**: Configurations such as `PGID`, `PUID`, and `TZ` are set in a ConfigMap for the application.

## Deployment
- **Target Namespace**: default
- **Release Name**: prowlarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The HelmRelease is configured to retry indefinitely on failure.
