---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# velero

## Overview
Velero is a backup and restore tool for Kubernetes clusters, enabling users to manage disaster recovery and data protection. It provides capabilities for scheduling backups, restoring resources, and managing backup storage locations. In this deployment, Velero is configured to work with AWS as the backup storage provider.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `velero--velero`
  - **Chart**: velero
  - **Version**: 12.0.0
  - **Target Namespace**: velero
  - **Provides**: Backup and restore functionality for Kubernetes resources.

## Dependencies
There are no explicit dependencies defined for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: velero
- **Repository**: vmware-tanzu (https://vmware-tanzu.github.io/helm-charts)
- **Version**: 12.0.0

## Resource Glossary
### Networking
- **Service**: A ClusterIP service named `velero` is created to expose the Velero server for monitoring purposes.

### Security
- **ServiceAccount**: A service account named `velero-server` is created for the Velero server to manage permissions.
- **Role**: A role named `velero-server` is created to grant permissions to the Velero server within the `velero` namespace.
- **RoleBinding**: A role binding named `velero-server` binds the `velero-server` role to the `velero-server` service account.
- **ClusterRoleBinding**: A cluster role binding named `velero-server` grants the `cluster-admin` role to the `velero-server` service account, allowing it to perform actions across the cluster.

### Storage
- **Secret**: A secret named `velero` is created to store cloud credentials required for accessing the backup storage.
- **ConfigMap**: A config map named `velero-repo-maintenance` is created to manage maintenance jobs for Velero.

### Workload
- **Deployment**: A deployment for the Velero server is created to manage the server's lifecycle.
- **DaemonSet**: A daemon set named `node-agent` is created to run a Velero node agent on each node in the cluster, facilitating backup operations.

## Configuration Highlights
- **Backup Storage Location**: Configured to use AWS with parameters such as bucket name and region defined as Flux variables (`${velero_backup_bucket}`, `${velero_backup_bucket_region}`).
- **Scheduling**: Backups are scheduled daily and weekly with specific retention policies.
- **Plugins**: Init containers are configured to use the Velero plugins for AWS and CSI.
- **Node Agent**: The node agent is deployed with specific security context settings and volume mounts for cloud credentials and host paths.

## Deployment
- **Target Namespace**: velero
- **Release Name**: velero
- **Reconciliation Interval**: 10m
- **Install/Upgrade Behavior**: The installation will retry indefinitely on failure, with a timeout of 15 minutes for each attempt.
