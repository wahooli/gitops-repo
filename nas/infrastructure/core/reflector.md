---
title: "reflector"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# reflector

## Overview
The `reflector` component is responsible for monitoring and reflecting Kubernetes resources. It operates within the `reflector` namespace and utilizes a Helm chart to manage its deployment and configuration. This component is part of the infrastructure core of the cluster.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `reflector--reflector`
  - **Chart**: `reflector`
  - **Version**: `7.1.262`
  - **Target Namespace**: `reflector`
  - **Provides**: A deployment that monitors Kubernetes resources and reflects their state.

## Helm Chart(s)
- **Chart Name**: `reflector`
- **Repository**: `emberstack` (https://emberstack.github.io/helm-charts)
- **Version**: `7.1.262`

## Resource Glossary
### Security
- **ServiceAccount**: A dedicated service account named `reflector` that the deployment uses to interact with the Kubernetes API.
- **ClusterRole**: Grants permissions to the `reflector` service account to manage configmaps, secrets, and watch namespaces.
- **ClusterRoleBinding**: Binds the `reflector` service account to the `reflector` cluster role, allowing it to perform actions defined in the role.

### Workload
- **Deployment**: Manages the deployment of the `reflector` application, ensuring that one replica is running. It includes:
  - **Container**: Runs the `emberstack/kubernetes-reflector:7.1.262` image.
  - **Probes**: Configured liveness, readiness, and startup probes to ensure the application is healthy.
  - **Environment Variables**: Configures logging levels and TLS verification settings.

### Configuration
- **ConfigMap**: 
  - `reflector-values-hk2hfcmmh5`: Contains operational settings such as tolerations and logging configuration.
  - `reflector-config`: Holds the logging configuration in JSON format for the `reflector` application.

## Configuration Highlights
- **Tolerations**: The deployment includes a toleration for critical addons, allowing it to run on nodes reserved for critical workloads.
- **Logging Configuration**: Configured to log at a minimum level of `Information`, with specific overrides for various components.
- **Security Context**: The deployment runs as the root user with specific security capabilities dropped.

## Deployment
- **Target Namespace**: `reflector`
- **Release Name**: `reflector`
- **Reconciliation Interval**: `10m`
- **Install Behavior**: The deployment is set to retry indefinitely on failure.
