---
title: "keda"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# keda

## Overview
KEDA (Kubernetes Event-driven Autoscaling) is a component that enables Kubernetes workloads to scale based on external events. It provides the ability to scale applications based on various event sources, allowing for efficient resource utilization and responsiveness to demand.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `keda--keda`
  - **Chart**: `keda`
  - **Version**: `2.19.0`
  - **Target Namespace**: `keda`
  - **Provides**: KEDA operator and associated resources for event-driven autoscaling.

## Helm Chart(s)
- **Chart Name**: `keda`
- **Repository**: `kedacore` (https://kedacore.github.io/charts)
- **Version**: `2.19.0`

## Resource Glossary
### Networking
- **Service**: Exposes the KEDA operator and metrics server, allowing communication within the cluster.
  
### Security
- **ServiceAccount**: Three service accounts are created for the KEDA operator, metrics server, and webhook, enabling them to interact with the Kubernetes API securely.
- **ClusterRole**: Defines permissions for the KEDA operator to manage resources across the cluster.
- **ClusterRoleBinding**: Binds the ClusterRole to the service accounts, granting them the defined permissions.

### Custom Resources
- **CustomResourceDefinition (CRD)**: Six CRDs are created, allowing users to define custom resources like `CloudEventSource`, which KEDA uses to scale applications based on events.

### Workload
- **Deployment**: Three deployments are created for the KEDA operator, metrics server, and webhook, managing the lifecycle of these components.

### Configuration
- **ConfigMap**: Contains base values and configurations for KEDA, allowing customization of its behavior.

## Configuration Highlights
- The KEDA operator is configured to use image tag `2.19.0`.
- The deployment includes settings for CRD creation and upgrade behavior, with a timeout of 10 minutes for installations.
- The reconciliation interval for the HelmRelease is set to 10 minutes.

## Deployment
- **Target Namespace**: `keda`
- **Release Name**: `keda`
- **Reconciliation Interval**: `10m`
- **Install Behavior**: Creates or replaces CRDs as needed.
