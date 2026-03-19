---
title: "vaultwarden"
parent: "Apps"
grand_parent: "tpi-1"
---

# Vaultwarden

## Overview

The `vaultwarden` component provides a self-hosted password management solution, deployed in the `tpi-1` Kubernetes cluster. It is based on the open-source Vaultwarden project, which is a lightweight alternative to Bitwarden. This deployment includes two sub-components: the Vaultwarden application and a PostgreSQL database for persistent storage.

## Sub-components

### Vaultwarden
- **Chart**: `vaultwarden`
- **Version**: `latest` (floating: `>=0.1.1-0`)
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Target Namespace**: `default`
- **Description**: Deploys the Vaultwarden application, including its Deployment, Service, PersistentVolumeClaim, and Ingress resources.

### PostgreSQL
- **Chart**: `postgresql`
- **Version**: `14.3.3`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Target Namespace**: `default`
- **Description**: Provides a PostgreSQL database for Vaultwarden to store its data. Includes a StatefulSet, Services, and a NetworkPolicy.

## Dependencies

The `vaultwarden` HelmRelease depends on the `vaultwarden-postgresql` HelmRelease. The PostgreSQL database is required to store Vaultwarden's data, including user credentials and other application-related information.

Dependency chain:
- `default--vaultwarden` → `default--vaultwarden-postgresql`

## Helm Chart(s)

### Vaultwarden
- **Chart**: `vaultwarden`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: `latest` (floating: `>=0.1.1-0`)

### PostgreSQL
- **Chart**: `postgresql`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: `14.3.3`

## Resource Glossary

### Vaultwarden Resources

#### Networking
- **Service**: Exposes the Vaultwarden application on ports 80 (HTTP), 443 (HTTPS), and 3012 (WebSocket) using a `ClusterIP` service.
- **Ingress**: Configures external access to Vaultwarden via the hostname `vault.wahoo.li`. Includes annotations for SSL redirection and custom NGINX settings.

#### Storage
- **PersistentVolumeClaim**: Allocates 10Gi of storage for Vaultwarden's `/data` directory to persist user data.

#### Workload
- **Deployment**: Runs the Vaultwarden application as a single replica with a `Recreate` update strategy. Includes readiness, liveness, and startup probes to ensure application health.

#### Security
- **ServiceAccount**: Provides a dedicated service account for the Vaultwarden application.

### PostgreSQL Resources

#### Networking
- **Services**: 
  - `vaultwarden-postgresql`: Exposes the PostgreSQL database on port 5432.
  - `vaultwarden-postgresql-hl`: A headless service for internal communication within the StatefulSet.
- **NetworkPolicy**: Restricts access to the PostgreSQL pods, allowing only necessary ingress and egress traffic.

#### Workload
- **StatefulSet**: Deploys a single replica of the PostgreSQL database with persistent storage and Velero backup hooks.

#### Security
- **ServiceAccount**: Provides a dedicated service account for the PostgreSQL database.

## Configuration Highlights

### Vaultwarden
- **Image**: `ghcr.io/dani-garcia/vaultwarden:1.35.4`
- **Resource Requests**: 
  - CPU: `600m`
  - Memory: `256Mi`
- **Resource Limits**:
  - Memory: `3072Mi`
- **Persistence**: 
  - 10Gi PVC mounted at `/data`.
- **Environment Variables**:
  - `ADMIN_TOKEN`, `PUSH_INSTALLATION_ID`, `PUSH_INSTALLATION_KEY`, and SMTP credentials are sourced from Kubernetes secrets.
  - Other configurations include `ROCKET_PORT`, `SMTP_FROM`, and `SMTP_PASSWORD`.

### PostgreSQL
- **Image**: `ghcr.io/wahooli/docker/postgresql:16.2.0`
- **Persistence**: 
  - 2Gi PVC for database storage.
- **Velero Backup Hooks**:
  - Pre-backup: Dumps the database to a file.
  - Post-restore: Restores the database from the backup file.

## Deployment

### Vaultwarden
- **Namespace**: `default`
- **Release Name**: `vaultwarden`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: Unlimited retries on failure.

### PostgreSQL
- **Namespace**: `default`
- **Release Name**: `vaultwarden-postgresql`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: Unlimited retries on failure.
