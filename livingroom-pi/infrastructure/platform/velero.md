---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# Velero

## Overview

Velero is a backup and recovery solution for Kubernetes clusters. It provides capabilities for backing up and restoring cluster resources and persistent volumes, performing disaster recovery, and migrating Kubernetes cluster resources to other clusters. In the `livingroom-pi` cluster, Velero is deployed using a HelmRelease managed by Flux.

## Helm Chart(s)

### velero--velero
- **Chart Name**: `velero`
- **Repository**: `vmware-tanzu` ([https://vmware-tanzu.github.io/helm-charts](https://vmware-tanzu.github.io/helm-charts))
- **Version**: `11.4.0`
- **Release Name**: `velero`
- **Target Namespace**: `velero`

## Resource Glossary

### Namespace
- **velero**: A dedicated namespace for all Velero-related resources.

### ServiceAccount
- **velero-server**: A service account used by the Velero server and its components to interact with the Kubernetes API and other resources.

### Secret
- **velero**: A secret containing cloud provider credentials for accessing the backup storage location.

### ConfigMap
- **velero-repo-maintenance**: Contains configuration for repository maintenance, such as the number of latest maintenance jobs to keep.

### ClusterRoleBinding
- **velero-server**: Grants cluster-wide permissions to the `velero-server` service account.

### Role and RoleBinding
- **velero-server**: Provides namespace-specific permissions for the `velero-server` service account.

### Service
- **velero**: A ClusterIP service exposing Velero's monitoring endpoint on port `8085`.

### Deployment
- **velero**: The main Velero server deployment responsible for managing backups, restores, and snapshots.

### DaemonSet
- **node-agent**: A DaemonSet that deploys the Velero node agent on each node in the cluster. The node agent facilitates backup and restore operations for persistent volumes.

### BackupStorageLocation
- **seaweedfs-backups**: Configures the default backup storage location for Velero. It uses an S3-compatible storage backend with configurable parameters such as bucket name, region, and access mode.

### ImageRepository and ImagePolicy
- **velero**: Tracks the Velero container image hosted on `ghcr.io/vmware-tanzu/charts/velero`.
- **velero-plugin-for-aws**: Tracks the AWS plugin container image hosted on `velero/velero-plugin-for-aws`.

## Configuration Highlights

- **Backup Storage**:
  - Default backup storage location: `seaweedfs-backups`
  - Provider: `aws`
  - Bucket: `${velero_backup_bucket}` (configurable via Flux variable)
  - Region: `${velero_backup_bucket_region}` (configurable via Flux variable)
  - S3 URL: `${velero_backup_bucket_url}` (configurable via Flux variable)
  - Public URL: `${velero_backup_bucket_public_url}` (configurable via Flux variable)
  - Access Mode: `ReadWrite`

- **Backup Schedules**:
  - **Weekly**: Runs every 7 days at 2:05 AM, retains backups for 30 days.
  - **Daily**: Runs daily at 1:05 AM, retains backups for 7 days.
  - **Hourly**: Disabled by default.

- **Plugins**:
  - AWS plugin: `velero/velero-plugin-for-aws:v1.14.0` (tracked via Flux ImagePolicy).
  - CSI plugin: `velero/velero-plugin-for-csi:v0.7.0`.

- **Node Agent**:
  - Deployed as a DaemonSet.
  - Uses the `velero-server` service account.
  - Monitors metrics on port `8085`.

- **DNS Configuration**:
  - `ndots: 1`
  - `edns0`

- **Other Settings**:
  - `upgradeCRDs`: `true`
  - `cleanUpCRDs`: `false`
  - Default backup TTL: `72h`
  - Log format: `json`

## Deployment

- **Target Namespace**: `velero`
- **Release Name**: `velero`
- **Reconciliation Interval**: `10m`
- **Install Behavior**:
  - Unlimited retries on failure.
  - Timeout: `15m`
- **Upgrade Behavior**:
  - Automatically remediates the last failure.

This deployment of Velero is configured to provide robust backup and recovery capabilities for the `livingroom-pi` cluster, with support for AWS S3-compatible storage and customizable backup schedules.
