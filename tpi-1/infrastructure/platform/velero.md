---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# velero

## Overview
Velero is a backup and restore tool for Kubernetes that enables users to protect their cluster resources and persistent volumes. It facilitates disaster recovery and data migration across clusters. In this deployment, Velero is configured to use AWS as the backup storage provider, with scheduled backups set up for daily and weekly intervals.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease: velero--velero**
  - **Chart:** velero
  - **Version:** 12.0.0
  - **Target Namespace:** velero
  - **Provides:** Backup and restore capabilities for Kubernetes resources and persistent volumes.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name:** velero
- **Repository:** vmware-tanzu (https://vmware-tanzu.github.io/helm-charts)
- **Version:** 12.0.0

## Resource Glossary
### Networking
- **Service:** A ClusterIP service named `velero` that exposes the Velero API for monitoring on port 8085.

### Security
- **ServiceAccount:** A service account named `velero-server` that allows Velero to interact with the Kubernetes API.
- **Role & RoleBinding:** A role named `velero-server` that grants permissions to the service account, allowing it to perform all actions on all resources within the `velero` namespace.
- **ClusterRoleBinding:** Binds the `velero-server` role to the service account, granting cluster-wide permissions.

### Storage
- **Secret:** A secret named `velero` that stores cloud credentials for accessing the backup storage.
- **ConfigMap:** A config map named `velero-repo-maintenance` that contains configuration for maintaining backup jobs.

### Workload
- **Deployment:** A deployment for the Velero server that manages the main Velero application.
- **DaemonSet:** A daemon set named `node-agent` that runs a Velero node agent on each node in the cluster, responsible for managing volume snapshots and backups.

## Configuration Highlights
- **Backup Storage Location:** Configured to use AWS with parameters such as bucket name and region defined as Flux variables (`${velero_backup_bucket}`, `${velero_backup_bucket_region}`).
- **Scheduled Backups:** Configured for daily and weekly backups with specific schedules and retention policies.
- **Plugins:** Includes plugins for AWS and CSI, with specific versions defined in the configuration.

## Deployment
- **Target Namespace:** velero
- **Release Name:** velero
- **Reconciliation Interval:** 10 minutes
- **Install/Upgrade Behavior:** The installation has a timeout of 15 minutes and will retry indefinitely on failure.
