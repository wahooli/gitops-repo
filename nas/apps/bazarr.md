---
title: "bazarr"
parent: "Apps"
grand_parent: "nas"
---

# Bazarr

## Overview
Bazarr is a companion application to Sonarr and Radarr, used for managing and downloading subtitles for movies and TV shows. It is deployed in the `nas` cluster and configured for GitOps management using Flux. The deployment leverages a Helm chart from the `wahooli` OCI repository and includes additional Kubernetes resources for networking, storage, and monitoring.

## Helm Chart(s)
- **Chart Name**: `bazarr`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `bazarr`
- **Target Namespace**: `default`

## Resource Glossary

### Networking
- **Ingress**: Configured with the `nginx` ingress class to expose Bazarr at `bazarr.wahoo.li` with HTTPS enabled. It includes annotations for external DNS and authentication integration with Authentik.
- **Service**: A ClusterIP service exposes Bazarr on port `6767` for HTTP traffic and port `9707` for metrics. It includes annotations for Cilium service mesh integration.
- **HTTPRoute**: Provides routing for Bazarr traffic via the `internal-gw` Gateway in the `infrastructure` namespace. The hostname is `bazarr.absolutist.it`.

### Storage
- **PersistentVolumeClaim**: A PVC named `config-bazarr` is provisioned with `1Gi` of storage and `ReadWriteOnce` access mode for storing configuration data. Additional hostPath volumes are mounted for movies and TV shows at `/movies` and `/tv`, respectively.

### Security
- **Certificate**: A TLS certificate is managed by cert-manager for the domain `bazarr.wahoo.li`, issued by the `letsencrypt-production` ClusterIssuer. The certificate is stored in the `tls-bazarr-ingress` secret.
- **ServiceAccount**: A dedicated ServiceAccount named `bazarr` is created for the Bazarr deployment.

### Monitoring
- **ServiceMonitor**: Configured to scrape metrics from the Bazarr metrics endpoint every 300 seconds with a scrape timeout of 60 seconds. Metrics are relabeled for clarity and to remove unnecessary labels.

### Image Management
- **ImageRepository**: Tracks the Bazarr image hosted on `ghcr.io/linuxserver/bazarr` with an update interval of 24 hours.
- **ImagePolicy**: Ensures the Bazarr image is updated based on the `x.x.x` semantic versioning range.

### Workload
- **Deployment**: A single-replica deployment of Bazarr with the following notable configurations:
  - **Image**: `ghcr.io/linuxserver/bazarr:1.5.6` (managed by ImagePolicy).
  - **Pod Annotations**: Includes annotations for Velero backup and Vector logging exclusion.
  - **DNS Configuration**: Custom DNS options (`ndots:1` and `edns0`).
  - **Exporter Container**: A sidecar container (`bazarr-exporter`) for exposing additional metrics.

### Configuration
- **ConfigMaps**:
  - `bazarr-values-dtt8b692t7`: Contains Helm values for the deployment, including persistence, metrics, and ingress settings.
  - `bazarr-env-h56d7dkf9f`: Provides environment variables such as `PUID`, `PGID`, and `TZ`.

## Configuration Highlights
- **Persistence**:
  - Configuration data is stored in a PVC with `1Gi` of storage.
  - HostPath volumes are used for movies (`/movies`) and TV shows (`/tv`), with paths configurable via the `bazarr_movies_host_path` and `bazarr_tv_host_path` parameters.
- **Metrics**:
  - Metrics collection is enabled with additional metrics exposed via the `bazarr-exporter` sidecar container.
  - Metrics are scraped at a 300-second interval with a 60-second timeout.
- **Ingress**:
  - HTTPS is enforced with a TLS certificate issued by Let's Encrypt.
  - Integrated with Authentik for authentication.
  - External DNS annotations for automatic DNS record management.
- **Environment Variables**:
  - `PUID`: `2003`
  - `PGID`: `2000`
  - `TZ`: `Europe/Helsinki`

## Deployment
- **Target Namespace**: `default`
- **Release Name**: `bazarr`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: Unlimited retries for remediation on installation failure.

This deployment is managed by Flux and uses a floating Helm chart version (`>=0.1.0-0`), ensuring it stays up-to-date with the latest chart releases from the `wahooli` repository. Configuration values are sourced from ConfigMaps, allowing for dynamic updates without requiring chart modifications.
