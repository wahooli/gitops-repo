---
title: "paperless-ngx"
parent: "Apps"
grand_parent: "tpi-1"
---

# paperless-ngx

## Overview

The `paperless-ngx` component is a document management system deployed on the `tpi-1` Kubernetes cluster. It is designed to digitize and organize paper documents, providing features such as OCR (Optical Character Recognition) and metadata management. This deployment uses a GitOps approach with Flux and consists of multiple HelmReleases for the main application and its dependencies.

## Sub-components

This deployment includes the following HelmReleases:

### 1. `default--paperless-ngx`
- **Chart**: `paperless-ngx`
- **Version**: `latest` (floating: `>=0.1.1-0`)
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Target Namespace**: `default`
- **Provides**: The main `paperless-ngx` application, including the web interface and document processing functionality.

### 2. `default--paperless-ngx-postgresql`
- **Chart**: `postgresql`
- **Version**: `14.3.3`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Target Namespace**: `default`
- **Provides**: PostgreSQL database for storing application data.

### 3. `default--paperless-ngx-redis`
- **Chart**: `redis`
- **Version**: `18.19.2`
- **Repository**: `bitnami` (https://charts.bitnami.com/bitnami)
- **Target Namespace**: `default`
- **Provides**: Redis for caching and message queuing.

## Dependencies

The `default--paperless-ngx` HelmRelease depends on:
- **`default--paperless-ngx-postgresql`**: Provides the PostgreSQL database backend for storing application data.
- **`default--paperless-ngx-redis`**: Provides Redis for caching and task queuing.

## Helm Chart(s)

### `default--paperless-ngx`
- **Chart**: `paperless-ngx`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: `latest` (floating: `>=0.1.1-0`)

### `default--paperless-ngx-postgresql`
- **Chart**: `postgresql`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: `14.3.3`

### `default--paperless-ngx-redis`
- **Chart**: `redis`
- **Repository**: `bitnami` (https://charts.bitnami.com/bitnami)
- **Version**: `18.19.2`

## Resource Glossary

### Networking
- **Ingress**: Configured for `paperless-ngx` to expose the web interface at `paperless.${domain_wahoo_li:=wahoo.li}` and `paperless.${domain_absolutist_it:=absolutist.it}`.
- **Service**: ClusterIP services for `paperless-ngx`, PostgreSQL, and Redis to enable internal communication.

### Storage
- **PersistentVolumeClaims (PVCs)**:
  - `data-paperless-ngx`: 10Gi storage for application data and media.
  - PostgreSQL and Redis also have PVCs for persistent data storage.

### Security
- **ServiceAccounts**:
  - `paperless-ngx`: Used by the main application.
  - `paperless-ngx-postgresql` and `paperless-ngx-redis`: Used by their respective sub-components.
- **NetworkPolicy**: Restricts access to the PostgreSQL database to authorized pods.

### Workloads
- **Deployments**:
  - `paperless-ngx`: Single replica with resource requests of 600m CPU and 2048Mi memory, and limits of 6144Mi memory.
- **StatefulSets**:
  - PostgreSQL and Redis are deployed as StatefulSets for persistent and reliable storage.

### Configuration
- **ConfigMaps**:
  - `paperless-ngx-env-6f77f9895k`: Contains environment variables for the application.
  - Additional ConfigMaps provide Helm values for the sub-components.

## Configuration Highlights

### paperless-ngx
- **Environment Variables**:
  - `PAPERLESS_PORT`: `8000`
  - `PAPERLESS_DBHOST`: `paperless-ngx-postgresql.default.svc.cluster.local.`
  - `PAPERLESS_REDIS`: `redis://paperless-ngx-redis-master.default.svc.cluster.local.:6379`
  - `PAPERLESS_TIME_ZONE`: `Europe/Helsinki`
  - `PAPERLESS_OCR_LANGUAGE`: `fin+eng`
- **Persistence**:
  - Data and media are stored in a 10Gi PVC.
- **Resource Requests and Limits**:
  - Requests: 600m CPU, 2048Mi memory
  - Limits: 6144Mi memory
- **Init Containers**:
  - `wait-for-redis` and `wait-for-psql` ensure Redis and PostgreSQL are ready before starting the main application.

### PostgreSQL
- **Persistence**: 4Gi PVC for database storage.
- **Authentication**:
  - Uses existing Kubernetes secrets for database credentials.
- **Backup Hooks**:
  - Pre-backup and post-restore hooks for database dump and restore.

### Redis
- **Persistence**: 1Gi PVC for Redis data.
- **Backup Hooks**:
  - Pre-backup and post-restore hooks for managing Redis data.

## Deployment

- **Target Namespace**: `default`
- **Release Names**:
  - `paperless-ngx`
  - `paperless-ngx-postgresql`
  - `paperless-ngx-redis`
- **Reconciliation Interval**: 5 minutes for all HelmReleases.
- **Install/Upgrade Behavior**: Unlimited retries for remediation on install failures.
