---
title: "radarr"
parent: "Apps"
grand_parent: "nas"
---

# Radarr

## Overview

Radarr is a movie collection manager for Usenet and BitTorrent users. It automates the process of downloading, organizing, and managing movies. In this Kubernetes deployment, Radarr is configured to run as a HelmRelease managed by Flux, ensuring continuous delivery and automated updates. The deployment includes additional resources for monitoring, ingress routing, and certificate management.

## Helm Chart(s)

### HelmRelease: `default--radarr`
- **Chart Name**: `radarr`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.1-0`)
- **Release Name**: `radarr`
- **Target Namespace**: `default`
- **Reconciliation Interval**: `5m`

## Resource Glossary

### Networking
- **Service**: A ClusterIP service named `radarr` exposes the application on port `7878` for HTTP traffic and port `9707` for metrics. It includes annotations for Cilium service discovery.
- **Ingress**: Configured with the `nginx` ingress class, the ingress routes traffic to `radarr.${domain_wahoo_li:=wahoo.li}`. It includes annotations for SSL redirection, custom HTTP error handling, and external DNS configuration.
- **HTTPRoute**: Provides routing for `radarr.${domain_absolutist_it:=absolutist.it}` via the `internal-gw` gateway in the `infrastructure` namespace.

### Storage
- **PersistentVolumeClaim**: A PVC named `config-radarr` is created with a storage request of `2Gi` and `ReadWriteOnce` access mode. It is used to persist configuration data.

### Security
- **ServiceAccount**: A ServiceAccount named `radarr` is created for the deployment. It is configured to automatically mount the service account token.
- **Certificate**: A certificate named `radarr-ingress` is issued using the `letsencrypt-production` ClusterIssuer. It secures the ingress with a TLS secret named `tls-radarr-ingress`.

### Workload
- **Deployment**: A single-replica Deployment named `radarr` is created. It includes:
  - A main container running the `ghcr.io/linuxserver/radarr:6.0.4` image.
  - A sidecar container running the `ghcr.io/onedr0p/exportarr:v2.0.1` image for metrics export.
  - Liveness, readiness, and startup probes for both containers.
  - Resource limits for the metrics exporter container: `150m` CPU and `60Mi` memory.
  - Persistent volume mounts for configuration (`/config`) and data (`/data/`).

### Monitoring
- **ServiceMonitor**: Configured to scrape metrics from the metrics endpoint (`/metrics`) every `300s` with a scrape timeout of `60s`. Includes relabeling configurations for Prometheus.

### Image Management
- **ImageRepository**: Tracks the `ghcr.io/linuxserver/radarr` image with an update interval of `24h`.
- **ImagePolicy**: Ensures the image tag follows a semantic versioning range (`x.x.x`).

### Configuration
- **ConfigMaps**:
  - `radarr-values-m8tf252d82`: Contains Helm values, including image tag, pod annotations, DNS configuration, metrics settings, and persistence configuration.
  - `radarr-env-gk9dgb4gfb`: Provides environment variables such as `PGID`, `PUID`, and `TZ`.

## Configuration Highlights

- **Image**: `ghcr.io/linuxserver/radarr:6.0.4`
- **Persistence**:
  - Configuration data is stored in a PVC with `2Gi` of storage.
  - Movie data is stored in a hostPath volume at `${radarr_data_host_path}`.
- **Probes**:
  - Liveness, readiness, and startup probes are configured for both the main container and the metrics exporter.
- **Metrics**:
  - Metrics are exposed on port `9707` via the `radarr-exporter` sidecar container.
  - ServiceMonitor is enabled for Prometheus integration.
- **Ingress**:
  - Configured with SSL termination using a Let's Encrypt certificate.
  - Routes traffic to `radarr.${domain_wahoo_li:=wahoo.li}` and `radarr.${domain_absolutist_it:=absolutist.it}`.

## Deployment

- **Target Namespace**: `default`
- **Release Name**: `radarr`
- **Reconciliation Interval**: `5m`
- **Install/Upgrade Behavior**: Unlimited retries on installation failure (`retries: -1`).
