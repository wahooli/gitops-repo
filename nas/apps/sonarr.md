---
title: "sonarr"
parent: "Apps"
grand_parent: "nas"
---

# Sonarr

## Overview
Sonarr is a PVR (Personal Video Recorder) application designed to automate the downloading and organization of TV shows. In the `nas` cluster, Sonarr is deployed using Flux GitOps with HelmRelease and integrated with various Kubernetes resources for networking, storage, and monitoring.

## Helm Chart(s)
- **Chart Name**: `sonarr`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.1-0`)

## Resource Glossary

### Networking
- **Service**: 
  - Type: `ClusterIP`
  - Ports:
    - `8989` (HTTP)
    - `9707` (Metrics)
  - Provides internal access to the Sonarr application and metrics.
- **Ingress**:
  - Class: `nginx`
  - Host: `sonarr.wahoo.li`
  - Annotations for SSL redirection and external DNS configuration.
  - Routes traffic to the Sonarr service.
- **HTTPRoute**:
  - Hostnames: `sonarr.absolutist.it`
  - Routes traffic to the Sonarr service via the internal gateway (`internal-gw`).

### Storage
- **PersistentVolumeClaim**:
  - Name: `config-sonarr`
  - Storage: `2Gi`
  - Mount Path: `/config`
  - Ensures persistent storage for Sonarr configuration data.

### Security
- **Certificate**:
  - DNS Name: `sonarr.wahoo.li`
  - Issuer: `letsencrypt-production`
  - Secret Name: `tls-sonarr-ingress`
  - Provides TLS encryption for secure communication.

### Monitoring
- **ServiceMonitor**:
  - Enabled: `true`
  - Scrape Interval: `300s`
  - Metrics are exposed via the `sonarr-exporter` container on port `9707`.

### Image Management
- **ImageRepository**:
  - Repository: `ghcr.io/linuxserver/sonarr`
  - Interval: `24h`
  - Ensures the latest image is tracked.
- **ImagePolicy**:
  - Policy: Semantic versioning (`x.x.x`)
  - Automatically updates the image based on the specified policy.

### Workload
- **Deployment**:
  - Name: `sonarr`
  - Replicas: `1`
  - Strategy: `Recreate`
  - Containers:
    - **Sonarr**:
      - Image: `ghcr.io/linuxserver/sonarr:4.0.16`
      - Ports: `8989` (HTTP)
      - Liveness, readiness, and startup probes configured for health checks.
    - **Sonarr Exporter**:
      - Image: `ghcr.io/onedr0p/exportarr:v2.0.1`
      - Exposes metrics on port `9707`.
      - Additional environment variables for enhanced metrics.

## Configuration Highlights
- **Environment Variables**:
  - `PGID`: `2003`
  - `PUID`: `2001`
  - `TZ`: `Europe/Helsinki`
- **Persistence**:
  - Configuration data stored in `/config` (PVC-backed).
  - Media data mounted at `/data/` (hostPath-backed).
- **Ingress Settings**:
  - SSL redirection enabled.
  - External DNS annotations for `sonarr.wahoo.li`.
- **Metrics**:
  - Additional metrics enabled via `ENABLE_ADDITIONAL_METRICS`.
  - Resource limits for metrics container: `200m CPU`, `60Mi Memory`.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `sonarr`
- **Reconciliation Interval**: `5m`
- **Install Behavior**: Unlimited retries for remediation.

This deployment integrates Sonarr with robust monitoring, secure networking, and persistent storage, ensuring high availability and operational efficiency in the `nas` cluster. Configurable parameters such as `${domain_wahoo_li}` and `${sonarr_data_host_path}` allow for customization based on the environment.
