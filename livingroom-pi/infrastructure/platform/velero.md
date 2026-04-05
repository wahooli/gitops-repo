---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# velero

## Overview
Velero is a backup and recovery solution for Kubernetes clusters. It allows users to back up their Kubernetes resources and persistent volumes, enabling disaster recovery and migration of workloads. In the livingroom-pi cluster, Velero is deployed to ensure that critical data and configurations are securely backed up and can be restored when necessary.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease:** velero--velero
  - **Chart:** velero
  - **Version:** 12.0.0
  - **Target Namespace:** velero
  - **Provides:** Backup and restore capabilities for Kubernetes resources and persistent volumes.

## Dependencies
There are no explicit dependencies defined for this HelmRelease.

## Helm Chart(s)
- **Chart Name:** velero
- **Repository:** vmware-tanzu (https://vmware-tanzu.github.io/helm-charts)
- **Version:** 12.0.0

## Resource Glossary
### Networking
- **Service:** A ClusterIP service named `velero` is created to expose the Velero server for monitoring purposes on port 8085.

### Security
- **ServiceAccount:** The `velero-server` ServiceAccount is created for the Velero server, allowing it to interact with the Kubernetes API.
- **Role:** A Role named `velero-server` is created in the `velero` namespace, granting permissions to manage all resources.
- **RoleBinding:** The RoleBinding associates the `velero-server` Role with the `velero-server` ServiceAccount.
- **ClusterRoleBinding:** A ClusterRoleBinding named `velero-server` is created to grant cluster-wide permissions to the Velero server.

### Storage
- **Secret:** A Secret named `velero` is created to store cloud provider credentials securely, allowing Velero to access the backup storage.

### Workload
- **Deployment:** The Velero server is deployed as a Deployment resource, managing the Velero application lifecycle.
- **DaemonSet:** A DaemonSet named `node-agent` is created to run Velero's node agent on each node in the cluster, facilitating backup of node-specific resources.

### Configuration
- **ConfigMap:** A ConfigMap named `velero-repo-maintenance` is created to manage Velero's maintenance job configurations.

## Configuration Highlights
- **Backup Storage Location:** Configured to use AWS S3 with parameters like bucket name and region sourced from Flux variables (`${velero_backup_bucket}`, `${velero_backup_bucket_region}`, etc.).
- **Snapshots Enabled:** Snapshots are enabled for certain configurations, while others are disabled.
- **Schedules:** Backup schedules are defined for daily and weekly backups, with specific retention policies.

## Deployment
- **Target Namespace:** velero
- **Release Name:** velero
- **Reconciliation Interval:** 10 minutes
- **Install/Upgrade Behavior:** The installation will retry indefinitely on failure, with a timeout of 15 minutes for each operation.
