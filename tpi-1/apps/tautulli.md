---
title: "tautulli"
parent: "Apps"
grand_parent: "tpi-1"
---

# Tautulli

## Overview

Tautulli is a monitoring and analytics tool for Plex Media Server, providing insights into media usage and server activity. This component is deployed in the `tpi-1` cluster using Flux GitOps and Helm. It includes configurations for persistent storage, ingress routing, and automated updates.

## Helm Chart(s)

### HelmRelease: `default--tautulli`
- **Chart Name**: `tautulli`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.1-0`)
- **Release Name**: `tautulli`
- **Target Namespace**: `default`
- **Reconciliation Interval**: `5m`

## Resource Glossary

### Networking
- **Ingress**: Routes external traffic to the Tautulli service. Configured with the hostname `tautulli.${domain_wahoo_li:=wahoo.li}` and uses the `nginx` ingress class. Includes annotations for SSL redirection, custom error handling, and external DNS integration.
- **HTTPRoute**: Provides routing for internal traffic via the `internal-gw` gateway in the `infrastructure` namespace. Routes traffic to the Tautulli service on port `8181`.

### Storage
- **PersistentVolumeClaim**: Ensures persistent storage for Tautulli's configuration data. The PVC `config-tautulli` requests `2Gi` of storage and is mounted at `/config` in the container.

### Security
- **Certificate**: Manages TLS for the ingress using the `letsencrypt-production` ClusterIssuer. The certificate is stored in the secret `tls-tautulli-ingress`.

### Workload
- **Deployment**: Runs the Tautulli application with a single replica. Configured with liveness, readiness, and startup probes to ensure application health. Uses the image `ghcr.io/linuxserver/tautulli:2.16.1`.
- **Service**: Exposes the Tautulli application internally on port `8181` using a `ClusterIP` service.

### Image Management
- **ImageRepository**: Monitors the image `ghcr.io/linuxserver/tautulli` for updates.
- **ImagePolicy**: Ensures the image follows the semantic versioning range `2.x.x`.

### Configuration
- **ConfigMap**: Stores Helm values for the Tautulli deployment, including environment variables, DNS settings, and persistence configurations.

## Configuration Highlights

- **Image**: `ghcr.io/linuxserver/tautulli:2.16.1` (managed by Flux ImagePolicy).
- **Environment Variables**:
  - `TZ`: `Europe/Helsinki` (sets the timezone).
- **Persistence**: Configuration data is stored in a PVC (`config-tautulli`) with `2Gi` of storage.
- **Ingress Annotations**:
  - SSL redirection (`nginx.ingress.kubernetes.io/force-ssl-redirect: "true"`).
  - External DNS targeting (`external-dns.alpha.kubernetes.io/target: gw.${domain_wahoo_li:=wahoo.li}`).
  - Custom error handling (`nginx.ingress.kubernetes.io/custom-http-errors: "404"`).
- **Probes**:
  - Liveness, readiness, and startup probes configured for port `8181` to ensure application health.

## Deployment

- **Target Namespace**: `default`
- **Release Name**: `tautulli`
- **Reconciliation Interval**: `5m`
- **Install/Upgrade Behavior**: Unlimited retries for installation remediation.

This deployment leverages Flux GitOps for automated reconciliation and Helm for application management. Configurable parameters such as `${domain_wahoo_li}` allow flexibility in adapting the deployment to different environments.
