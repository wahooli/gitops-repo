---
title: "topolvm"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# TopoLVM

## Overview
TopoLVM is a Container Storage Interface (CSI) plugin designed to provide logical volume management for Kubernetes clusters. It enables dynamic provisioning of persistent volumes using device classes, thin provisioning, and advanced storage features. In this deployment, TopoLVM is configured to manage storage across multiple device classes and integrates with Kubernetes to provide storage classes for dynamic volume provisioning.

## Dependencies
TopoLVM has a dependency on `cert-manager--cert-manager`. This dependency ensures that certificate management is available for webhook functionality, which is required for certain TopoLVM features like pod mutating webhooks.

## Helm Chart(s)
- **Chart Name:** `topolvm`
- **Repository:** [TopoLVM Helm Repository](https://topolvm.github.io/topolvm)
- **Version:** `15.6.1`

## Resource Glossary
### Storage
- **StorageClass (2):**
  - `topolvm-default`: Default storage class configured with `thinmirror` device class, XFS filesystem, and dynamic volume provisioning.
  - `topolvm-fast`: Secondary storage class configured with `nvme` device class, XFS filesystem, and dynamic volume provisioning.

### Security
- **ServiceAccount (4):** Service accounts for various TopoLVM components:
  - `topolvm-controller`: Used by the controller for managing logical volumes.
  - `topolvm-lvmd`: Used by the LVMD daemon for device management.
  - `topolvm-node`: Used by the node daemon for volume operations.
  - `topolvm-scheduler`: Used by the scheduler for custom scheduling logic.

- **ClusterRole (5) & ClusterRoleBinding (5):** Define permissions for TopoLVM components to interact with Kubernetes resources.

- **Role (4) & RoleBinding (4):** Namespace-specific permissions for TopoLVM components.

### Workloads
- **DaemonSet (3):** Deploys TopoLVM components as daemonsets across the cluster:
  - `lvmd`: Manages logical volume devices.
  - `scheduler`: Implements custom scheduling logic for TopoLVM volumes.
  - `node`: Handles volume operations on individual nodes.

- **Deployment (1):** Deploys the TopoLVM controller, responsible for managing the lifecycle of logical volumes.

### Configuration
- **ConfigMap (2):** Stores configuration data for TopoLVM components:
  - `topolvm-lvmd-0`: Configuration for LVMD, including device classes and thin pool settings.
  - `topolvm-scheduler-options`: Configuration for the scheduler, including listening address and divisor settings.

### Networking
- **Service (1):** Exposes the TopoLVM controller for internal communication.

### Priority
- **PriorityClass (1):** Defines a priority class for pods using TopoLVM volumes, ensuring they are scheduled with high priority.

### Resilience
- **PodDisruptionBudget (1):** Ensures availability of the TopoLVM controller during disruptions by allowing only one pod to be unavailable at a time.

### Custom Resources
- **CustomResourceDefinition (1):** Defines the `LogicalVolume` resource, enabling Kubernetes to manage logical volumes as native objects.

## Configuration Highlights
- **Device Classes:** Two device classes are configured:
  - `thinmirror`: Default device class with thin provisioning and a 5.0 overprovision ratio.
  - `nvme`: High-performance device class with thin provisioning and a 5.0 overprovision ratio.

- **Scheduler:** Enabled as a daemonset to provide custom scheduling for TopoLVM volumes.

- **Controller:** Configured with a single replica and storage capacity tracking disabled.

- **Storage Classes:** Two storage classes (`topolvm-default` and `topolvm-fast`) are defined with XFS filesystem, dynamic provisioning, and volume expansion enabled.

- **Pod Security Policy:** Disabled in this deployment.

- **Priority Class:** Configured with a value of `1000000` to prioritize pods using TopoLVM volumes.

## Deployment
- **Target Namespace:** `topolvm-system`
- **Release Name:** `topolvm`
- **Reconciliation Interval:** 10 minutes
- **Install Behavior:** Unlimited retries with a timeout of 15 minutes.
- **Upgrade Behavior:** Automatically remediates the last failure during upgrades.

## Notes
- Flux variables such as `${ssd_lvm_volumegroup}` and `${nvme_lvm_volumegroup}` are placeholders for configuration values that should be defined in the environment.
- The webhook functionality is enabled for pod mutating operations, enhancing integration with Kubernetes scheduling.
