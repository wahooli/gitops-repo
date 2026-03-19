---
title: "topolvm"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# TopoLVM

## Overview
TopoLVM is a CSI (Container Storage Interface) driver designed to manage LVM (Logical Volume Manager) volumes in Kubernetes clusters. It provides dynamic provisioning of persistent volumes, enabling efficient storage management and allocation. This deployment integrates TopoLVM into the cluster `tpi-1` and configures it to support thin-provisioned storage classes.

## Dependencies
TopoLVM relies on `cert-manager` for certificate management, which is required for its webhook functionality. Ensure that `cert-manager` is deployed and operational in the cluster before deploying TopoLVM.

## Helm Chart(s)
- **Chart Name:** `topolvm`
- **Repository:** [TopoLVM Helm Repository](https://topolvm.github.io/topolvm)
- **Version:** `15.5.2`

## Resource Glossary
### Storage
- **StorageClass (`topolvm-default`)**: Defines the default storage class for TopoLVM. It uses the `xfs` filesystem and supports volume expansion. Volumes are provisioned using the `thinpool` device class with a `WaitForFirstConsumer` binding mode, ensuring volumes are only created when a pod is scheduled.

### Security
- **PriorityClass (`topolvm`)**: Ensures that pods using TopoLVM volumes are assigned a high priority (`1,000,000`), preventing eviction during resource contention.
- **PodDisruptionBudget (`topolvm-controller`)**: Limits disruptions to the TopoLVM controller pods, ensuring at least one pod remains available during updates or failures.

### Networking
- **Service (`topolvm-controller`)**: Provides internal communication for the TopoLVM controller.
- **MutatingWebhookConfiguration**: Enables dynamic injection of volume-related configurations into pods using TopoLVM.

### Workload
- **DaemonSets**: 
  - **Scheduler**: Deploys a custom scheduler for TopoLVM to optimize volume placement.
  - **Node**: Manages TopoLVM node functionality for volume provisioning.
  - **Lvmd**: Handles LVM operations on cluster nodes.
- **Deployment (`topolvm-controller`)**: Ensures high availability of the TopoLVM controller with a single replica.

### Configuration
- **ConfigMaps**:
  - **topolvm-lvmd-0**: Configures LVM device classes, including the `thinpool` class with overprovisioning settings.
  - **topolvm-scheduler-options**: Provides options for the custom scheduler, such as listening address and divisor settings.

### Custom Resource Definitions (CRDs)
- **LogicalVolume (`logicalvolumes.topolvm.io`)**: Defines the schema for logical volumes managed by TopoLVM, including attributes like size, device class, and node affinity.

## Configuration Highlights
- **Scheduler**: Enabled as a DaemonSet to optimize volume scheduling.
- **Lvmd**: Configured to manage LVM device classes, with support for thin provisioning and overprovisioning.
- **Controller**: Single replica deployment with storage capacity tracking disabled.
- **Storage Classes**: Configured with `topolvm-default` as the default storage class, supporting dynamic provisioning and volume expansion.
- **Webhook**: Pod mutating webhook enabled for dynamic configuration injection.

## Deployment
- **Target Namespace:** `topolvm-system`
- **Release Name:** `topolvm`
- **Reconciliation Interval:** Every 10 minutes
- **Install Behavior:** Retries indefinitely on failure, with a timeout of 15 minutes.
- **Upgrade Behavior:** Automatically remediates the last failure during upgrades.

### Configurable Parameters
- **LVM Volume Group (`${lvm_volumegroup}`)**: Specifies the volume group for LVM operations.
- **Thin Pool Name (`${lvm_thinpool_name}`)**: Defines the name of the thin pool used for provisioning.
- **Kubelet Work Directory (`${kubelet_workdir}`)**: Configurable node-specific directory for kubelet operations.

This deployment ensures efficient storage management for Kubernetes workloads, leveraging LVM's capabilities for dynamic provisioning and thin provisioning.
