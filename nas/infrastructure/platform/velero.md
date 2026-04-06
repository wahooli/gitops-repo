---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# velero

## Overview
Velero is a backup and restore tool for Kubernetes that allows users to manage backups of their cluster resources and persistent volumes. It provides capabilities for disaster recovery and data migration, ensuring that critical data is protected and can be restored when needed.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `velero--velero`
  - **Chart**: `velero`
  - **Version**: `12.0.0`
  - **Target Namespace**: `velero`
  - **Provides**: Backup and restore functionality for Kubernetes resources and persistent volumes.

## Dependencies
There are no explicit dependencies defined for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `velero`
- **Repository**: `vmware-tanzu` (https://vmware-tanzu.github.io/helm-charts)
- **Version**: `12.0.0`

## Resource Glossary
### Networking
- **Service**: A `ClusterIP` service named `velero` that exposes the Velero API for monitoring on port `8085`.

### Security
- **ServiceAccount**: A service account named `velero-server` that allows Velero to interact with the Kubernetes API.
- **Role**: A role named `velero-server` that grants permissions to the Velero service account to manage all resources in the `velero` namespace.
- **RoleBinding**: Binds the `velero-server` role to the `velero-server` service account, allowing it to perform actions defined in the role.
- **ClusterRoleBinding**: Grants the `velero-server` service account cluster-wide permissions by binding it to the `cluster-admin` role.

### Storage
- **Secret**: A secret named `velero` that stores cloud credentials for accessing the backup storage provider.
- **ConfigMap**: A config map named `velero-repo-maintenance` that contains settings for maintaining backup repositories.

### Workload
- **Deployment**: Deploys the Velero server component that handles backup and restore operations.
- **DaemonSet**: Deploys a node agent that runs on each node in the cluster, facilitating backup and restore operations for persistent volumes.

## Configuration Highlights
- **Backup Storage Location**: Configured to use AWS with parameters such as `bucket`, `region`, and `s3Url` defined as Flux variables.
- **Scheduling**: Supports multiple backup schedules (daily, weekly) with customizable retention policies.
- **Init Containers**: Includes init containers for plugins like `velero-plugin-for-aws` and `velero-plugin-for-csi`, ensuring the necessary plugins are available before the main containers start.

## Deployment
- **Target Namespace**: `velero`
- **Release Name**: `velero`
- **Reconciliation Interval**: `10m`
- **Install/Upgrade Behavior**: The installation has a timeout of `15m` and will retry indefinitely on failure. The upgrade process will remediate any last failure automatically.
