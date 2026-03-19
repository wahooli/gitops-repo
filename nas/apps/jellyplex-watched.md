---
title: "jellyplex-watched"
parent: "Apps"
grand_parent: "nas"
---

# jellyplex-watched

## Overview
The `jellyplex-watched` component is a Kubernetes deployment that synchronizes watched status and playback progress between Jellyfin and Plex media servers. It is deployed in the `nas` cluster and is managed using Flux GitOps. The component uses a Helm chart to define its configuration and resources.

## Helm Chart(s)
- **Chart Name**: `jellyplex-watched`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)

## Resource Glossary

### Workload
- **Deployment**: 
  - **Name**: `jellyplex-watched`
  - **Replicas**: 1
  - **Image**: `ghcr.io/luigi311/jellyplex-watched:6.0.1`
  - **Ports**: 
    - `9000/TCP` (metrics)
  - **DNS Configuration**: 
    - `ndots: 1`
    - `edns0`
  - **Annotations**: 
    - Default container: `jellyplex-watched`
  - **Labels**: 
    - `app.kubernetes.io/name: jellyplex-watched`
    - `app.kubernetes.io/instance: jellyplex-watched`
    - `app.kubernetes.io/part-of: jellyplex-watched`

### Configuration
- **ConfigMap**: 
  - **Name**: `jellyplex-watched-values-8b4h86kmth`
  - **Purpose**: Provides Helm values for the deployment, including image tag, service configuration, and environment variables.
  - **Key Values**:
    - `image.tag`: `6.0.1`
    - `service.main.type`: `ClusterIP`
    - `service.main.ports`: 
      - `metrics: 9000/TCP`
    - `envFrom`:
      - ConfigMap: `jellyplex-watched-env`
      - Secret: `jellyplex-watched-tokens`

- **ConfigMap**: 
  - **Name**: `jellyplex-watched-env-hhf6bct6kd`
  - **Purpose**: Provides environment variables for the application.
  - **Key Variables**:
    - `DEBUG`: `False`
    - `DEBUG_LEVEL`: `info`
    - `JELLYFIN_BASEURL`: `http://jellyfin.default.svc.cluster.local.:8096`
    - `PLEX_BASEURL`: `http://plex.default.svc.cluster.local.:32400`
    - `MAX_THREADS`: `12`
    - `SYNC_FROM_JELLYFIN_TO_PLEX`: `True`
    - `SYNC_FROM_PLEX_TO_JELLYFIN`: `True`

### Image Management
- **ImageRepository**: 
  - **Name**: `jellyplex-watched`
  - **Image**: `ghcr.io/luigi311/jellyplex-watched`
  - **Update Interval**: 24 hours

## Configuration Highlights
- **Image Version**: The deployment uses the image `ghcr.io/luigi311/jellyplex-watched:6.0.1`.
- **Environment Variables**: Configured via a ConfigMap and Secret, enabling flexible updates without redeploying the application.
- **Service**: Exposes a single port (`9000/TCP`) for metrics collection.
- **DNS Configuration**: Custom DNS options (`ndots: 1` and `edns0`) are set for the pod.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `jellyplex-watched`
- **Reconciliation Interval**: 5 minutes
- **Install Behavior**: Unlimited retries on installation failure (`retries: -1`).

This component is managed by Flux and reconciled automatically based on the specified HelmRelease configuration.
