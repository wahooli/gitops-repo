---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# velero

## Overview
Velero is a backup and recovery tool for Kubernetes clusters, enabling users to back up their cluster resources and persistent volumes. It provides disaster recovery capabilities and allows for the migration of workloads between clusters. In this deployment, Velero is configured to use AWS as the backup storage provider.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease: velero--velero**
  - **Chart:** velero
  - **Version:** 12.0.0
  - **Target Namespace:** velero
  - **Provides:** Backup and recovery functionality for Kubernetes resources and persistent volumes.

## Dependencies
This deployment does not have any explicit dependencies listed in the HelmRelease.

## Helm Chart(s)
- **Chart Name:** velero
- **Repository:** vmware-tanzu (https://vmware-tanzu.github.io/helm-charts)
- **Version:** 12.0.0

## Resource Glossary
### Networking
- **Service:** A ClusterIP service named `velero` that exposes the Velero API for monitoring on port 8085.

### Security
- **ServiceAccount:** A service account named `velero-server` that allows Velero to interact with the Kubernetes API.
- **Role & RoleBinding:** A role and role binding named `velero-server` that grants the service account permissions to perform all actions on all resources within the `velero` namespace.
- **ClusterRoleBinding:** A cluster role binding named `velero-server` that grants the service account cluster-wide permissions.

### Storage
- **Secret:** A secret named `velero` that stores cloud credentials for accessing the backup storage.
- **ConfigMap:** A config map named `velero-repo-maintenance` that contains configuration for maintaining Velero's backup repository.

### Workload
- **Deployment:** A deployment for the Velero server that manages the Velero API and backup operations.
- **DaemonSet:** A daemon set named `node-agent` that runs on each node, allowing Velero to manage backups of persistent volumes.

## Configuration Highlights
- **Backup Storage Location:** Configured to use AWS with parameters such as bucket name and region specified via Flux variables (`${velero_backup_bucket}`, `${velero_backup_bucket_region}`).
- **Scheduling:** Configured schedules for daily and weekly backups with specific retention times.
- **Init Containers:** Includes init containers for plugins, such as `velero-plugin-for-aws` and `velero-plugin-for-csi`, with specific image versions.
- **Node Agent:** The node agent runs with a security context that allows it to access host paths for managing Kubernetes pods and plugins.

## Deployment
- **Target Namespace:** velero
- **Release Name:** velero
- **Reconciliation Interval:** 10 minutes
- **Install/Upgrade Behavior:** The installation has a timeout of 15 minutes and retries indefinitely on failure. Hooks are disabled during upgrades.
