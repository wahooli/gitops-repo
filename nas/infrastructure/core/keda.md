---
title: "keda"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# keda

## Overview
KEDA (Kubernetes Event-driven Autoscaling) is a component that enables Kubernetes workloads to scale based on external events. It provides a way to automatically scale applications based on metrics from various sources, allowing for efficient resource utilization in a Kubernetes cluster.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `keda--keda`
  - **Chart**: `keda`
  - **Version**: `2.19.0`
  - **Target Namespace**: `keda`
  - **Provides**: KEDA operator and related resources for event-driven scaling.

## Dependencies
This HelmRelease does not have any specified dependencies.

## Helm Chart(s)
- **Chart Name**: `keda`
- **Repository**: `kedacore` (https://kedacore.github.io/charts)
- **Version**: `2.19.0`

## Resource Glossary
### Networking
- **Service**: Exposes the KEDA operator and metrics server to other components within the cluster.
  
### Security
- **ServiceAccount**: Three service accounts are created for the KEDA operator, metrics server, and webhook, allowing them to interact with the Kubernetes API securely.

### Custom Resources
- **CustomResourceDefinition (CRD)**: Six CRDs are created, enabling the use of KEDA-specific resources like `CloudEventSource` for event-driven scaling.

### Workload
- **Deployment**: Three deployments are created for the KEDA operator, metrics server, and webhook, managing the lifecycle of these components.

### Configuration
- **ConfigMap**: A ConfigMap is created to hold base values and configurations for KEDA.

## Configuration Highlights
- The KEDA operator is configured to use the image `ghcr.io/kedacore/keda` with the tag `2.20.1`.
- The deployment includes settings for creating and replacing Custom Resource Definitions (CRDs) during installation and upgrades.

## Deployment
- **Target Namespace**: `keda`
- **Release Name**: `keda`
- **Reconciliation Interval**: `10m`
- **Install Behavior**: CRDs are created or replaced as needed. The installation has a timeout of `10m` and allows for unlimited retries on failure.
