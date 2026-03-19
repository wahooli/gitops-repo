---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# Velero

## Overview

Velero is a backup and recovery solution for Kubernetes clusters and persistent volumes. It provides disaster recovery and data migration capabilities by enabling users to back up and restore their cluster resources and persistent volumes. In the `tpi-1` cluster, Velero is deployed using a HelmRelease managed by Flux.

## Helm Chart(s)

### Velero HelmRelease
- **Chart Name**: `velero`
- **Repository**: `vmware-tanzu` ([https://vmware-tanzu.github.io/helm-charts](https://vmware-tanzu.github.io/helm-charts))
- **Version**: `11.4.0`

## Resource Glossary

### Core Resources
- **Namespace (`velero`)**: Dedicated namespace for Velero resources.
- **ServiceAccount (`velero-server`)**: Service account used by Velero to interact with the Kubernetes API and manage resources.
- **Deployment**: The main Velero server deployment, responsible for managing backup and restore operations.
- **DaemonSet (`node-agent`)**: Runs Velero node agents on each node in the cluster for managing volume snapshots and backups.

### Networking
- **Service (`velero`)**: Exposes Velero's monitoring endpoint on port `8085` using a `ClusterIP` service.

### Security
- **Secret (`velero`)**: Stores cloud provider credentials for accessing the backup storage location.
- **Role and RoleBinding (`velero-server`)**: Provides namespace-scoped permissions for Velero to manage resources.
- **ClusterRoleBinding (`velero-server`)**: Grants cluster-wide permissions to the Velero service account.

### Configuration
- **ConfigMap (`velero-repo-maintenance`)**: Contains configuration for repository maintenance, such as the number of maintenance jobs to retain.
- **BackupStorageLocation**: Configures the default backup storage location for Velero. In this deployment, backups are stored in an S3-compatible storage bucket (`seaweedfs-backups`).

### Scheduling
- **Schedules**: Velero is configured with predefined backup schedules:
  - **Weekly**: Runs every 7 days at 2:05 AM, retaining backups for 30 days.
  - **Daily**: Runs every day at 1:05 AM, retaining backups for 7 days.
  - **Hourly**: Disabled by default.

## Configuration Highlights

- **Backup Storage**:
  - Default backup storage location: `seaweedfs-backups`
  - Provider: `aws`
  - Bucket: `${velero_backup_bucket}` (configurable via Flux variable)
  - Region: `${velero_backup_bucket_region}` (configurable via Flux variable)
  - S3 URL: `${velero_backup_bucket_url}` (configurable via Flux variable)
  - Public URL: `${velero_backup_bucket_public_url}` (configurable via Flux variable)
  - Access Mode: `ReadWrite`
- **Plugins**:
  - AWS Plugin: `velero/velero-plugin-for-aws:v1.14.0` (managed by Flux ImagePolicy)
  - CSI Plugin: `velero/velero-plugin-for-csi:v0.7.0`
- **Node Agent**:
  - Deployed as a DaemonSet.
  - Uses the `velero-server` ServiceAccount.
  - Configured with a termination grace period of 3600 seconds.
- **DNS Configuration**:
  - `ClusterFirstWithHostNet` policy for DNS resolution.
  - Custom DNS options: `ndots:1` and `edns0`.
- **Resource Exclusions**:
  - Excluded resources: Specific Kubernetes resources such as `storageclasses`, `certificaterequests`, `ciliumendpoints`, and others.
  - Excluded namespaces: System and infrastructure-related namespaces such as `kube-system`, `cert-manager`, `ingress-nginx`, and `velero`.

## Deployment

- **Target Namespace**: `velero`
- **Release Name**: `velero`
- **Reconciliation Interval**: Every 10 minutes
- **Install Behavior**: Unlimited retries with a timeout of 15 minutes.
- **Upgrade Behavior**: Automatically remediates the last failure during upgrades.

This deployment is managed by Flux and uses a HelmRelease to ensure the desired state is maintained. Configuration values are sourced from multiple ConfigMaps, allowing for flexible and centralized management of Velero settings.
