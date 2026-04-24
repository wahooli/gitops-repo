---
title: "reflector"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# reflector

## Overview
The `reflector` component is responsible for monitoring Kubernetes resources and reflecting their state. It operates within the `livingroom-pi` cluster and is deployed in the `reflector` namespace. This component utilizes the Helm chart from the Emberstack repository to manage its deployment and configuration.

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
- **Namespace**: 
  - `reflector`: A dedicated namespace for the reflector component, isolating its resources.
  
- **HelmRepository**: 
  - `emberstack`: Defines the source of the Helm chart used for deployment.

- **HelmRelease**: 
  - `reflector--reflector`: Manages the lifecycle of the reflector deployment.

- **ConfigMap**: 
  - `reflector-values-hk2hfcmmh5`: Contains configuration values for the reflector, including tolerations and logging settings.
  - `reflector-config`: Holds the logging configuration in JSON format for the reflector application.

- **ServiceAccount**: 
  - `reflector`: Provides an identity for the reflector application to interact with the Kubernetes API.

- **Deployment**: 
  - `reflector`: Deploys the reflector application, specifying its container image, resource limits, and health checks.

- **ClusterRole**: 
  - `reflector`: Grants permissions to the reflector application to access necessary Kubernetes resources.

- **ClusterRoleBinding**: 
  - `reflector`: Binds the `reflector` ClusterRole to the `reflector` ServiceAccount, allowing it to perform actions defined in the ClusterRole.

## Configuration Highlights
- **Tolerations**: The reflector pod is configured with a toleration for `CriticalAddonsOnly`, allowing it to be scheduled on nodes reserved for critical workloads.
- **Logging Configuration**: The logging level is set to `Information`, and the application is configured to skip TLS verification for Kubernetes API calls.
- **Security Context**: The reflector runs as a non-root user with specific capabilities dropped for enhanced security.

## Deployment
- **Target Namespace**: `reflector`
- **Release Name**: `reflector`
- **Reconciliation Interval**: `10m`
- **Install Behavior**: The deployment will retry indefinitely on failure, ensuring resilience.
