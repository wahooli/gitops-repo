---
title: "velero"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# velero

## Overview
Velero is a backup and restore tool for Kubernetes, enabling users to manage disaster recovery and data protection for their cluster resources and persistent volumes. This deployment in the `livingroom-pi` cluster utilizes the Helm chart version 12.0.0 from the VMware Tanzu repository.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `velero--velero`
  - **Chart**: velero
  - **Version**: 12.0.0
  - **Target Namespace**: velero
  - **Provides**: Backup and restore capabilities for Kubernetes resources and persistent volumes.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: velero
- **Repository**: vmware-tanzu (https://vmware-tanzu.github.io/helm-charts)
- **Version**: 12.0.0

## Resource Glossary
### Networking
- **Service**: A ClusterIP service named `velero` is created to expose the Velero API for monitoring on port 8085.

### Security
- **ServiceAccount**: A service account named `velero-server` is created for the Velero server to interact with the Kubernetes API.
- **Role**: A role named `velero-server` is created, granting permissions to all resources and verbs within the `velero` namespace.
- **RoleBinding**: Binds the `velero-server` role to the `velero-server` service account, allowing it to perform actions defined in the role.
- **ClusterRoleBinding**: Grants the `velero-server` service account cluster-admin permissions, allowing it to manage resources across the cluster.

### Storage
- **Secret**: A secret named `velero` is created to store cloud credentials for backup operations.

### Workload
- **Deployment**: A deployment for the Velero server is created to manage the Velero application.
- **DaemonSet**: A node agent daemon set is created to run Velero on each node, facilitating backup operations for node-specific resources.

### Configuration
- **ConfigMap**: A config map named `velero-repo-maintenance` is created to manage maintenance job configurations.

## Configuration Highlights
- **Backup Storage Location**: Configured to use AWS S3 with parameters such as `bucket`, `region`, and `s3Url` defined as Flux variables.
- **Scheduling**: Backup schedules are defined for daily and weekly backups with specific retention policies.
- **Node Agent**: The node agent is deployed with specific configurations for monitoring and backup operations.

## Deployment
- **Target Namespace**: velero
- **Release Name**: velero
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: The deployment will retry indefinitely on failure and has a timeout of 15 minutes for installation.
