---
title: "prowlarr"
parent: "Apps"
grand_parent: "nas"
---

# Prowlarr

## Overview

Prowlarr is a lightweight application designed to manage and automate the tracking of media indexers for applications like Sonarr and Radarr. It provides a unified interface to manage indexers and integrates seamlessly with other media management tools. In this deployment, Prowlarr is configured to run in the `default` namespace of the `nas` cluster, managed via Flux and Helm.

## Helm Chart(s)

### HelmRelease: `default--prowlarr`
- **Chart Name**: `prowlarr`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `prowlarr`
- **Target Namespace**: `default`
- **Reconciliation Interval**: 5 minutes

## Resource Glossary

### Networking
- **Service (`prowlarr`)**: Exposes the Prowlarr application within the cluster as a `ClusterIP` service on port `9696` for HTTP traffic and port `9707` for metrics. It includes annotations for Cilium service configuration.
- **HTTPRoute (`prowlarr`)**: Configures routing for the Prowlarr application via the `internal-gw` gateway in the `infrastructure` namespace. The route is accessible at `prowlarr.absolutist.it` and forwards traffic to the Prowlarr service on port `9696`.
- **Certificate (`prowlarr-ingress`)**: Manages TLS certificates for the Prowlarr ingress, issued by the `letsencrypt-production` ClusterIssuer. The certificate is stored in the `tls-prowlarr-ingress` secret.

### Storage
- **PersistentVolumeClaim (`config-prowlarr`)**: Allocates 1Gi of persistent storage for Prowlarr's configuration data. The volume is mounted at `/config` in the Prowlarr container.

### Workload
- **Deployment (`prowlarr`)**: Manages the Prowlarr application with the following specifications:
  - **Replicas**: 1
  - **Strategy**: Recreate
  - **Containers**:
    - **Prowlarr**:
      - Image: `ghcr.io/linuxserver/prowlarr:2.3.0`
      - Ports: `9696` (HTTP)
      - Probes: Liveness, readiness, and startup probes configured on port `9696`.
      - Volume Mounts: `/config` for persistent configuration storage.
    - **Prowlarr Exporter**:
      - Image: `ghcr.io/onedr0p/exportarr:v2.0.1`
      - Ports: `9707` (Metrics)
      - Environment Variables: `CONFIG`, `PORT`, and `URL` for exporter configuration.
      - Volume Mounts: Read-only access to `/config`.

### Security
- **ServiceAccount (`prowlarr`)**: A dedicated service account for the Prowlarr deployment with token automount enabled.

### Image Management
- **ImageRepository (`prowlarr`)**: Tracks the `ghcr.io/linuxserver/prowlarr` image with an update interval of 24 hours.
- **ImagePolicy (`prowlarr`)**: Ensures the Prowlarr image is updated to the latest version matching the semantic versioning range `x.x.x`.

### Configuration Management
- **ConfigMap (`prowlarr-values-494g2f9445`)**: Stores Helm values for the Prowlarr deployment, including:
  - Image tag: `2.3.0`
  - Pod annotations for backup and metrics exclusion.
  - Resource configuration for metrics endpoint.
  - Persistence settings for configuration data.
  - Service annotations for Cilium and ingress settings.
- **ConfigMap (`prowlarr-env-c4cc549kk5`)**: Stores environment variables for the Prowlarr application, including:
  - `PGID`: `1000`
  - `PUID`: `1000`
  - `TZ`: `Europe/Helsinki`

## Configuration Highlights

- **Resource Requests and Limits**:
  - Metrics container: CPU limit `100m`, memory limit `60Mi`.
  - Main container: Resource requests and limits are commented out but can be configured as needed.
- **Persistence**:
  - Configuration data is stored in a PersistentVolumeClaim with 1Gi of storage.
- **Metrics**:
  - Metrics are enabled and exposed on port `9707` via the `prowlarr-exporter` container.
  - A ServiceMonitor is created to scrape metrics, with custom relabeling configurations.
- **DNS and Ingress**:
  - DNS is configured with `ndots:1` and `edns0` options.
  - Ingress is disabled in favor of HTTPRoute for routing.
  - External DNS annotations are included for integration with Cloudflare.

## Deployment

- **Target Namespace**: `default`
- **Release Name**: `prowlarr`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: Unlimited retries for remediation in case of failure.
