---
title: "seaweedfs-csi-driver"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs-csi-driver

## Overview
The SeaweedFS CSI Driver is a Container Storage Interface (CSI) driver that allows Kubernetes to manage SeaweedFS storage. It provides persistent storage capabilities for Kubernetes workloads, enabling seamless integration with SeaweedFS as a backend storage solution.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `seaweedfs--seaweedfs-csi-driver`
  - **Chart**: `seaweedfs-csi-driver`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `seaweedfs`
  - **Provides**: Persistent storage capabilities via SeaweedFS.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `seaweedfs-csi-driver`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Security
- **ServiceAccount**: 
  - `seaweedfs-csi-driver-controller`: Used by the CSI controller to interact with the Kubernetes API.
  - `seaweedfs-csi-driver-node`: Used by the CSI node service to manage volumes on the nodes.
  - `seaweedfs-csi-driver-node-gc`: Used by the garbage collection process for the CSI driver.

### Configuration
- **ConfigMap**: 
  - `seaweedfs-csi-driver-shared-config`: Contains configuration settings for the SeaweedFS driver, including TLS settings and CORS policies.
  - `seaweedfs-csi-driver-mount-extra-scripts`: Holds scripts for mounting operations.
  - `seaweedfs-csi-driver-node-gc-entrypoint`: Contains the entrypoint script for the garbage collection process.

### Storage
- **StorageClass**: Defines the storage class for dynamic provisioning of SeaweedFS volumes.

### Access Control
- **ClusterRoleBinding**: Grants necessary permissions to the CSI driver components.
- **ClusterRole**: Defines the permissions for the CSI driver.
- **RoleBinding**: Binds the role to the service account for namespace-specific permissions.
- **Role**: Defines permissions for the CSI driver within a specific namespace.

### Workload Management
- **DaemonSet**: Ensures that a copy of the SeaweedFS CSI driver runs on each node in the cluster.
- **Deployment**: Manages the SeaweedFS CSI controller, ensuring it runs and is updated as needed.
- **CSIDriver**: Registers the SeaweedFS CSI driver with Kubernetes.

## Configuration Highlights
- **Image Repository**: `chrislusf/seaweedfs-csi-driver` with tag `v1.4.26`.
- **TLS**: TLS is enabled with an existing secret named `seaweedfs-shared`.
- **Data Locality**: Set to `none`, indicating no specific data locality requirements.
- **Filer Address**: Configured to `seaweedfs-filer-lb.seaweedfs.svc.cluster.local:8888`.
- **Node Garbage Collection**: Enabled with a specific image for the garbage collection process.

## Deployment
- **Target Namespace**: `seaweedfs`
- **Release Name**: `seaweedfs-csi-driver`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure.
