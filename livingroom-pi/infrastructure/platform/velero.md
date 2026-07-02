---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# velero

## Overview
Velero is a backup and restore tool for Kubernetes that enables users to manage their cluster data effectively. It provides capabilities for backing up Kubernetes resources and persistent volumes, allowing for disaster recovery and migration of workloads. This deployment consists of a single HelmRelease that encapsulates the Velero functionality.

## Sub-components
This deployment includes the following HelmRelease:
- **HelmRelease**: `velero--velero`
  - **Chart**: velero
  - **Version**: 12.1.0
  - **Target Namespace**: velero
  - **Provides**: Backup and restore capabilities for Kubernetes resources and persistent volumes.

## Dependencies
This deployment does not have any explicit dependencies defined in the HelmRelease.

## Helm Chart(s)
- **Chart Name**: velero
- **Repository**: vmware-tanzu (https://vmware-tanzu.github.io/helm-charts)
- **Version**: 12.1.0

## Resource Glossary
### Networking
- **Service**: A ClusterIP service named `velero` that exposes the Velero API for monitoring on port 8085.

### Security
- **ServiceAccount**: A service account named `velero-server` that allows Velero to interact with the Kubernetes API.
- **Role**: A role named `velero-server` that grants permissions to the Velero service account to perform all actions on all resources within the `velero` namespace.
- **RoleBinding**: Binds the `velero-server` role to the `velero-server` service account, allowing it to use the permissions defined in the role.
- **ClusterRoleBinding**: Grants the `velero-server` service account cluster-wide permissions as a cluster-admin.

### Storage
- **Secret**: A secret named `velero` that contains cloud credentials necessary for backup operations.
- **ConfigMap**: A configuration map named `velero-repo-maintenance` that holds global settings for maintenance jobs.

### Workload
- **Deployment**: A deployment that manages the Velero server, ensuring it runs the necessary containers for backup and restore operations.
- **DaemonSet**: A daemon set named `node-agent` that runs on each node, allowing Velero to interact with the node's resources.

## Configuration Highlights
- **Backup Storage Location**: Configured to use AWS with parameters such as bucket name and region sourced from Flux variables (`${velero_backup_bucket}`, `${velero_backup_bucket_region}`).
- **Scheduling**: Weekly and daily backup schedules are defined with specific retention policies.
- **Plugins**: Init containers for AWS and CSI plugins are included, allowing Velero to handle various storage types.

## Deployment
- **Target Namespace**: velero
- **Release Name**: velero
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: The installation has a timeout of 15 minutes and will retry indefinitely on failure. The upgrade process is configured to remediate the last failure automatically.
