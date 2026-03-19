---
title: "overseerr"
parent: "Apps"
grand_parent: "tpi-1"
---

# Overseerr

## Overview

Overseerr is a media request and management tool that integrates with services like Plex and Sonarr. It provides a user-friendly interface for managing media requests and automates the process of fetching and organizing media. In this deployment, Overseerr is configured to run in the `tpi-1` Kubernetes cluster, managed via Flux and Helm.

## Helm Chart(s)

### HelmRelease: `default--overseerr`
- **Chart Name**: `overseerr`
- **Version**: `latest` (floating: `>=0.1.1-0`)
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Release Name**: `overseerr`
- **Target Namespace**: `default`
- **Reconciliation Interval**: `5m`

## Resource Glossary

### Networking
- **Ingress**: 
  - Provides external access to the Overseerr service via the hostname `overseerr.${domain_wahoo_li}`. 
  - Configured with annotations to enforce SSL redirection and optimize proxy timeouts.
  - Uses the `nginx` ingress class.
- **Service**: 
  - Exposes the Overseerr application internally within the cluster on port `5055` using a `ClusterIP` service.

### Storage
- **PersistentVolumeClaim**: 
  - Allocates 2Gi of persistent storage for the application configuration at `/app/config`.
  - Configured with `ReadWriteOnce` access mode to ensure exclusive access by a single node.

### Security
- **ServiceAccount**: 
  - A dedicated service account named `overseerr` is created for the application, ensuring proper access control and isolation.

### Workload
- **Deployment**: 
  - Overseerr is deployed as a single replica with a rolling update strategy.
  - Configured with liveness, readiness, and startup probes to monitor application health.
  - The container runs the image `ghcr.io/lenaxia/overseerr-oidc:oidc-support` with the following environment variables:
    - `LOG_LEVEL`: `warn`
    - `PORT`: `5055`
    - `TZ`: `Europe/Helsinki`
  - The deployment uses a persistent volume for storing configuration data and includes annotations for backup.

## Configuration Highlights

- **Image**: The deployment uses the custom image `ghcr.io/lenaxia/overseerr-oidc:oidc-support` with `IfNotPresent` pull policy.
- **Environment Variables**:
  - `LOG_LEVEL`: Set to `warn` for reduced verbosity in logs.
  - `TZ`: Configured to `Europe/Helsinki` for timezone settings.
- **Persistence**:
  - A PersistentVolumeClaim is used to store configuration data, ensuring data is retained across pod restarts.
  - The volume is mounted at `/app/config`.
- **Ingress Annotations**:
  - `nginx.ingress.kubernetes.io/force-ssl-redirect`: Ensures HTTPS is enforced.
  - `nginx.ingress.kubernetes.io/proxy-read-timeout` and `nginx.ingress.kubernetes.io/proxy-send-timeout`: Set to `3600` seconds to handle long-running requests.
  - `external-dns.alpha.kubernetes.io/target`: Configured to point to `gw.${domain_wahoo_li}`.
  - `external-dns.alpha.kubernetes.io/cloudflare-proxied`: Set to `false`.

## Deployment

- **Target Namespace**: `default`
- **Release Name**: `overseerr`
- **Reconciliation Interval**: Every `5m`
- **Install/Upgrade Behavior**: 
  - Automatic retries are enabled with unlimited attempts (`retries: -1`).

This deployment is managed by Flux and uses a HelmRelease to ensure the application is always in the desired state. Configuration values are sourced from a ConfigMap (`overseerr-values-c682m64m6t`), allowing for centralized management of application settings.
