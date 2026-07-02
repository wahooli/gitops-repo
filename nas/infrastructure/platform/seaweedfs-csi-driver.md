---
title: "seaweedfs-csi-driver"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs-csi-driver

## Overview
The `seaweedfs-csi-driver` is a Container Storage Interface (CSI) driver for SeaweedFS, enabling Kubernetes to manage SeaweedFS volumes. It facilitates dynamic provisioning and management of storage resources within Kubernetes clusters, allowing applications to utilize SeaweedFS for persistent storage.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `seaweedfs--seaweedfs-csi-driver`
  - **Chart**: `seaweedfs-csi-driver`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `seaweedfs`
  - **Provides**: CSI driver functionality for SeaweedFS, including necessary Kubernetes resources for operation.

## Dependencies
This component does not have any explicit dependencies defined in the HelmRelease.

## Helm Chart(s)
- **Chart Name**: `seaweedfs-csi-driver`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Security
- **ServiceAccount**: Three service accounts are created for the CSI driver:
  - `seaweedfs-csi-driver-controller`: Used by the controller component.
  - `seaweedfs-csi-driver-node`: Used by the node component.
  - `seaweedfs-csi-driver-node-gc`: Used for garbage collection tasks.

### Configuration
- **ConfigMap**: 
  - `seaweedfs-csi-driver-shared-config`: Contains configuration for CORS, access controls, and TLS settings for gRPC and HTTPS communications.
  - `seaweedfs-csi-driver-mount-extra-scripts`: Includes a wrapper script for the `weed` command.
  - `seaweedfs-csi-driver-node-gc-entrypoint`: Contains a script for the garbage collection process.

### Storage
- **StorageClass**: Defines the storage class for dynamic provisioning of SeaweedFS volumes.

### Roles and Permissions
- **ClusterRole**: Grants permissions to the CSI driver components to interact with Kubernetes resources.
- **ClusterRoleBinding**: Binds the ClusterRole to the service accounts, allowing them to perform actions defined in the role.
- **Role**: Provides namespace-specific permissions.
- **RoleBinding**: Binds the Role to a service account within the `seaweedfs` namespace.

### Workload Management
- **DaemonSet**: Ensures that a copy of the CSI driver runs on each node in the cluster, allowing for volume management across all nodes.
- **Deployment**: Manages the controller component of the CSI driver.

### CSI Driver
- **CSIDriver**: Registers the SeaweedFS CSI driver with Kubernetes, enabling it to be used for volume management.

## Configuration Highlights
- **Image**: The driver uses the image `chrislusf/seaweedfs-csi-driver` with the tag `v1.4.23`.
- **TLS**: TLS is enabled for secure communication, with an existing secret specified for certificates.
- **Data Locality**: Configured to `none`, indicating that data locality is not enforced.
- **Filer Address**: Set to `seaweedfs-filer-lb.seaweedfs.svc.cluster.local:8888`, which is the endpoint for the SeaweedFS filer service.
- **Node Garbage Collection**: Enabled with a specified image for the garbage collection process.

## Deployment
- **Target Namespace**: `seaweedfs`
- **Release Name**: `seaweedfs-csi-driver`
- **Reconciliation Interval**: 5 minutes
- **Install Behavior**: The installation will retry indefinitely on failure, as indicated by `remediation.retries: -1`.
