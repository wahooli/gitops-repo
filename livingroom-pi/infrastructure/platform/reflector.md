---
title: "reflector"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# Reflector

## Overview

The `reflector` component is responsible for synchronizing Kubernetes ConfigMaps and Secrets across namespaces. It uses the [Emberstack Reflector](https://github.com/emberstack/kubernetes-reflector) Helm chart to deploy a Kubernetes controller that watches for changes in ConfigMaps and Secrets and replicates them to other namespaces as configured. This is particularly useful for ensuring consistent configuration and secret management across multiple namespaces in a Kubernetes cluster.

## Helm Chart(s)

### reflector--reflector
- **Chart Name**: `reflector`
- **Version**: `7.1.262`
- **Repository**: [emberstack](https://emberstack.github.io/helm-charts)
- **Release Name**: `reflector`
- **Target Namespace**: `reflector`
- **Reconciliation Interval**: 10 minutes

## Resource Glossary

### Namespace
- **reflector**: A dedicated namespace created for the `reflector` component to isolate its resources.

### HelmRepository
- **emberstack**: A Helm repository pointing to `https://emberstack.github.io/helm-charts`, which hosts the `reflector` Helm chart.

### HelmRelease
- **reflector--reflector**: Manages the deployment of the `reflector` Helm chart in the `reflector` namespace.

### ConfigMaps
1. **reflector-values-hk2hfcmmh5**: Provides custom configuration values for the Helm chart, including tolerations, Kubernetes settings, logging configuration, and security context.
2. **reflector-config**: Contains a JSON configuration file (`reflector.logging.json`) for Serilog logging settings.

### ServiceAccount
- **reflector**: A service account used by the `reflector` Deployment to interact with the Kubernetes API.

### ClusterRole
- **reflector**: Grants permissions to the `reflector` ServiceAccount to manage ConfigMaps, Secrets, and watch/list namespaces.

### ClusterRoleBinding
- **reflector**: Binds the `reflector` ServiceAccount to the `reflector` ClusterRole, enabling it to perform the necessary operations.

### Deployment
- **reflector**: The main workload for the `reflector` component. It runs a single replica of the `emberstack/kubernetes-reflector:7.1.262` container. The Deployment includes the following configurations:
  - **ServiceAccount**: Uses the `reflector` ServiceAccount for API access.
  - **Security Context**: Configured to run as root (`runAsUser: 0`) with no dropped capabilities and a writable root filesystem.
  - **Probes**: Includes liveness, readiness, and startup probes to monitor the health of the application.
  - **Environment Variables**:
    - `ES_Serilog__MinimumLevel__Default`: Sets the default logging level to `Information`.
    - `ES_Reflector__Watcher__Timeout`: Configures the watcher timeout (empty by default).
    - `ES_Reflector__Kubernetes__SkipTlsVerify`: Skips TLS verification for Kubernetes API calls (`true`).
  - **Ports**: Exposes the application on port `25080` for HTTP traffic.
  - **Volumes**: Mounts the `reflector-config` ConfigMap to `/app/reflector.logging.json` for logging configuration.
  - **Tolerations**: Allows scheduling on nodes with the `CriticalAddonsOnly` taint.

## Configuration Highlights

- **Logging**: Configured using a JSON file (`reflector.logging.json`) stored in the `reflector-config` ConfigMap. It uses Serilog for structured logging with a minimum log level of `Information`.
- **Security Context**: The container runs as root (`runAsUser: 0`) with a writable root filesystem. This may require additional scrutiny for security-sensitive environments.
- **Tolerations**: Configured to tolerate the `CriticalAddonsOnly` taint, allowing deployment on critical nodes.
- **Probes**: Includes liveness, readiness, and startup probes to ensure the application is healthy and ready to serve traffic.

## Deployment

- **Target Namespace**: `reflector`
- **Release Name**: `reflector`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: Configured with unlimited retries (`retries: -1`) for remediation during installation or upgrades. 

This deployment ensures that the `reflector` component is continuously monitored and reconciled by Flux, maintaining its desired state in the cluster.
