---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# Velero

## Overview

Velero is a backup and recovery solution for Kubernetes clusters and persistent volumes. It provides disaster recovery and data migration capabilities, allowing you to back up your cluster resources and persistent volumes, restore them in case of failure, and migrate resources to other clusters. In the `nas` cluster, Velero is deployed using a HelmRelease managed by Flux.

## Helm Chart(s)

### velero--velero
- **Chart Name**: `velero`
- **Repository**: [vmware-tanzu](https://vmware-tanzu.github.io/helm-charts)
- **Version**: `11.4.0`
- **Release Name**: `velero`
- **Target Namespace**: `velero`
- **Reconciliation Interval**: 10 minutes

## Resource Glossary

The Velero deployment creates the following Kubernetes resources:

### Core Resources
- **Namespace (`velero`)**: Dedicated namespace for Velero resources.
- **Deployment (`velero`)**: The main Velero server responsible for managing backups and restores.
- **DaemonSet (`node-agent`)**: Runs the Velero node agent on each node for handling volume snapshots and backups.

### Networking
- **Service (`velero`)**: Exposes the Velero server for monitoring purposes on port `8085`.

### Security
- **ServiceAccount (`velero-server`)**: Service account used by the Velero server and node agent.
- **Role (`velero-server`)**: Provides permissions for Velero operations within the `velero` namespace.
- **RoleBinding (`velero-server`)**: Binds the `velero-server` Role to the `velero-server` ServiceAccount.
- **ClusterRoleBinding (`velero-server`)**: Grants cluster-wide permissions to the Velero server.

### Configuration
- **ConfigMap (`velero-repo-maintenance`)**: Contains configuration for repository maintenance, such as the number of maintenance jobs to keep.
- **Secret (`velero`)**: Stores cloud provider credentials for accessing backup storage.

### Backup and Restore
- **BackupStorageLocation (`seaweedfs-backups`)**: Configures the backup storage location using an S3-compatible storage backend.
- **Schedule**: Predefined backup schedules:
  - **Daily**: Retains backups for 7 days.
  - **Weekly**: Retains backups for 30 days.

## Configuration Highlights

- **Backup Storage**: Configured to use an S3-compatible storage backend (`seaweedfs-backups`) with customizable parameters:
  - `bucket`: `${velero_backup_bucket}`
  - `region`: `${velero_backup_bucket_region}`
  - `s3Url`: `${velero_backup_bucket_url}`
  - `publicUrl`: `${velero_backup_bucket_public_url}`
- **Plugins**:
  - Velero Plugin for AWS (`velero/velero-plugin-for-aws:v1.14.0`)
  - Velero Plugin for CSI (`velero/velero-plugin-for-csi:v0.7.0`)
- **Snapshots**: Enabled by default.
- **Backup Schedules**:
  - **Daily**: Runs at `1:05 AM` and retains backups for 7 days.
  - **Weekly**: Runs every 7 days at `2:05 AM` and retains backups for 30 days.
  - **Hourly**: Disabled by default.
- **Excluded Resources**: Specific Kubernetes resources (e.g., `storageclasses.storage.k8s.io`, `certificaterequests.cert-manager.io`) and namespaces (e.g., `kube-system`, `cert-manager`) are excluded from backups.
- **Node Agent**: Deployed to manage volume snapshots, with a `dnsPolicy` set to `ClusterFirst`.

## Deployment

- **Target Namespace**: `velero`
- **Release Name**: `velero`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**:
  - **Install Timeout**: 15 minutes
  - **Upgrade Hooks**: Disabled
  - **Remediation**: Automatic retries for failed installations and upgrades (`remediateLastFailure: true`).

This deployment is managed by Flux, with configuration values sourced from multiple ConfigMaps (`velero-values-2tmfhddtk8`). Key parameters, such as storage backend details and credentials, are dynamically populated using Flux variables.
