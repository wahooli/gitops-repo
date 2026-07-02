---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# velero

## Overview
Velero is a backup and restore tool for Kubernetes that helps manage disaster recovery and data protection. It allows users to back up their Kubernetes cluster resources and persistent volumes, and restore them when needed. In this deployment, Velero is configured to work with AWS as the backup storage provider.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease: velero--velero**
  - **Chart:** velero
  - **Version:** 12.1.0
  - **Target Namespace:** velero
  - **Provides:** Backup and restore capabilities for Kubernetes resources and persistent volumes.

## Dependencies
This deployment does not have any specific dependencies listed.

## Helm Chart(s)
- **Chart Name:** velero
- **Repository:** vmware-tanzu (https://vmware-tanzu.github.io/helm-charts)
- **Version:** 12.1.0

## Resource Glossary
### Networking
- **Service:** A ClusterIP service named `velero` is created to expose the Velero server for monitoring purposes.

### Security
- **ServiceAccount:** A service account named `velero-server` is created for the Velero server to manage permissions.
- **Role & RoleBinding:** A role named `velero-server` is created with permissions to access all resources, bound to the `velero-server` service account.

### Storage
- **Secret:** A secret named `velero` is created to store cloud credentials for AWS, allowing Velero to access the backup storage.
- **ConfigMap:** A ConfigMap named `velero-repo-maintenance` is created to manage maintenance jobs for Velero.

### Workload
- **Deployment:** A deployment for the Velero server is created to manage the Velero application.
- **DaemonSet:** A node agent daemon set is created to run Velero on each node, enabling it to back up and restore workloads.

## Configuration Highlights
- **Backup Storage Location:** Configured to use AWS with a bucket defined by the variable `${velero_backup_bucket}` and region `${velero_backup_bucket_region}`.
- **Schedules:** Weekly and daily backup schedules are defined, with specific labels and retention settings.
- **Init Containers:** Two init containers are defined for plugins: `velero-plugin-for-csi` and `velero-plugin-for-aws`, with specific images and volume mounts.
- **Node Agent:** The node agent is deployed with a security context that allows it to run as root and includes configurations for monitoring.

## Deployment
- **Target Namespace:** velero
- **Release Name:** velero
- **Reconciliation Interval:** 10m
- **Install/Upgrade Behavior:** The installation has a timeout of 15 minutes and will retry indefinitely on failure.
