---
title: "transmission-old"
parent: "Apps"
grand_parent: "nas"
---

# transmission-old

## Overview

The `transmission-old` component is a deployment of the Transmission BitTorrent client in the `nas` cluster. It is managed using Flux and Helm, and is configured to run in the `default` namespace. This component provides a web-based interface for managing torrent downloads and is configured with persistent storage for configuration and downloaded files.

## Helm Chart(s)

### HelmRelease: `default--transmission-old`
- **Chart Name**: `transmission`
- **Chart Version**: `latest` (floating: `>=0.1.0-0`)
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Release Name**: `transmission-old`
- **Target Namespace**: `default`
- **Reconciliation Interval**: 5 minutes

## Resource Glossary

### Networking
- **HTTPRoute**: 
  - Name: `transmission-old`
  - Exposes the Transmission web UI on the following hostnames:
    - `transmission-old.absolutist.it`
    - `transmission-old.wahoo.li`
  - Routes traffic to the `transmission-old` service on port `9091`.

- **Service**:
  - Name: `transmission-old`
  - Type: `ClusterIP`
  - Exposes the Transmission web UI on port `9091`.

### Storage
- **PersistentVolumeClaim**:
  - Name: `config-transmission-old`
  - Provides persistent storage for the `/config` directory.
  - Storage Request: `1Gi`
  - Access Mode: `ReadWriteOnce`
- **HostPath Volume**:
  - Path: `${transmission_old_downloads_host_path}`
  - Provides storage for the `/downloads` directory.

### Workload
- **Deployment**:
  - Name: `transmission-old`
  - Replicas: 1
  - Strategy: `Recreate`
  - Container:
    - Image: `ghcr.io/linuxserver/transmission:4.0.5-r3-ls240`
    - Ports: 
      - `9091` (web UI)
    - Resource Requests:
      - CPU: `300m`
    - Resource Limits:
      - CPU: `1000m`
    - Probes:
      - Liveness, readiness, and startup probes configured on port `9091`.
    - Volume Mounts:
      - `/config` (backed by `config-transmission-old` PVC)
      - `/downloads` (backed by hostPath volume)

### Configuration
- **ConfigMap**:
  - Name: `transmission-old-env-4mtg676425`
  - Environment Variables:
    - `PGID`: `2003`
    - `PUID`: `2004`
    - `TZ`: `Europe/Helsinki`
- **ConfigMap**:
  - Name: `transmission-old-values-7ktc4ttmtk`
  - Contains Helm values for the deployment, including:
    - `image.tag`: `4.0.5-r3-ls240`
    - `strategy.type`: `Recreate`
    - `dnsConfig`: Custom DNS options
    - `persistence`: Configuration for persistent storage of `/config` and `/downloads` directories.
    - `global.labels`: Labels for backup configuration.

### Image Automation
- **ImagePolicy**:
  - Name: `transmission-old`
  - Tracks the image repository `ghcr.io/linuxserver/transmission`.
  - Filters tags matching the pattern `4.0.5-r(?P<release>[0-9]+)-ls(?P<build>[0-9]+)`.
  - Automatically selects the latest tag based on alphabetical order.

## Configuration Highlights

- **Image**: `ghcr.io/linuxserver/transmission:4.0.5-r3-ls240` (managed by Flux ImagePolicy).
- **Resource Requests and Limits**:
  - CPU Request: `300m`
  - CPU Limit: `1000m`
- **Persistence**:
  - `/config`: Backed by a PersistentVolumeClaim with `1Gi` storage.
  - `/downloads`: Backed by a hostPath volume at `${transmission_old_downloads_host_path}`.
- **Environment Variables**:
  - `PGID`: `2003`
  - `PUID`: `2004`
  - `TZ`: `Europe/Helsinki`
- **Probes**:
  - Liveness, readiness, and startup probes configured for the web UI on port `9091`.

## Deployment

- **Target Namespace**: `default`
- **Release Name**: `transmission-old`
- **Reconciliation Interval**: 5 minutes
- **Install Behavior**: Unlimited retries on failure (`remediation.retries: -1`).

This deployment is configured to run with a single replica and uses a `Recreate` deployment strategy. It is accessible via the specified hostnames and is integrated with Flux for automated image updates and configuration management.
