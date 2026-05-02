---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# velero

## Overview
Velero is a backup and recovery tool for Kubernetes clusters. It enables users to take snapshots of their cluster's resources and persistent volumes, allowing for disaster recovery and migration of workloads. In this deployment, Velero is configured to use AWS as the backup storage provider.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `velero--velero`
  - **Chart**: velero
  - **Version**: 12.0.1
  - **Target Namespace**: velero
  - **Provides**: Backup and restore capabilities for Kubernetes resources and persistent volumes.

## Dependencies
There are no explicit dependencies defined for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: velero
- **Repository**: vmware-tanzu (https://vmware-tanzu.github.io/helm-charts)
- **Version**: 12.0.1

## Resource Glossary
### Networking
- **Service**: A ClusterIP service named `velero` that exposes the Velero API for monitoring purposes.

### Security
- **ServiceAccount**: A service account named `velero-server` used by Velero to interact with the Kubernetes API.
- **Role**: A role named `velero-server` that grants permissions to the Velero service account to manage all resources in the `velero` namespace.
- **RoleBinding**: Binds the `velero-server` role to the `velero-server` service account, allowing it to perform actions defined in the role.
- **ClusterRoleBinding**: Binds the `velero-server` role to the service account at the cluster level, granting it cluster-wide permissions.

### Workload
- **Deployment**: Manages the Velero server application, ensuring it runs continuously and can be scaled as needed.
- **DaemonSet**: Deploys a node agent on each node in the cluster to facilitate backup operations for workloads running on those nodes.

### Configuration
- **ConfigMap**: Contains configuration data for Velero, including backup schedules and storage location settings.

## Configuration Highlights
- **Backup Storage Location**: Configured to use AWS with a bucket specified by the variable `${velero_backup_bucket}`.
- **Backup Schedules**: 
  - Weekly backups are scheduled every 7 days.
  - Daily backups are scheduled every day at 1:05 AM.
- **Node Agent**: The node agent is deployed to each node, allowing for the backup of local persistent volumes.

## Deployment
- **Target Namespace**: velero
- **Release Name**: velero
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: The installation has a timeout of 15 minutes and will retry indefinitely in case of failure.
