---
title: "reflector"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# Reflector

## Overview

The `reflector` component is a Kubernetes deployment that uses the [EmberStack Reflector](https://github.com/emberstack/kubernetes-reflector) Helm chart. It is designed to synchronize Kubernetes ConfigMaps and Secrets across namespaces, ensuring consistent configuration and secret management in the cluster. This component is deployed in the `nas` cluster.

## Helm Chart(s)

- **Chart Name**: `reflector`
- **Repository**: [EmberStack Helm Charts](https://emberstack.github.io/helm-charts)
- **Version**: `7.1.262`

## Resource Glossary

### Namespace
- **Name**: `reflector`
- **Purpose**: Provides an isolated namespace for the `reflector` component's resources.

### HelmRepository
- **Name**: `emberstack`
- **Namespace**: `flux-system`
- **Purpose**: Defines the source of the Helm chart for the `reflector` component. It points to the EmberStack Helm Charts repository.

### HelmRelease
- **Name**: `reflector--reflector`
- **Namespace**: `flux-system`
- **Purpose**: Manages the deployment of the `reflector` Helm chart. It ensures the chart is installed and reconciled at regular intervals.

### ServiceAccount
- **Name**: `reflector`
- **Namespace**: `reflector`
- **Purpose**: Provides the necessary identity for the `reflector` Deployment to interact with the Kubernetes API.

### ClusterRole
- **Name**: `reflector`
- **Purpose**: Grants permissions to the `reflector` component to manage ConfigMaps, Secrets, and watch namespaces.

### ClusterRoleBinding
- **Name**: `reflector`
- **Purpose**: Binds the `reflector` ServiceAccount to the `reflector` ClusterRole, enabling the necessary permissions.

### Deployment
- **Name**: `reflector`
- **Namespace**: `reflector`
- **Purpose**: Runs the `reflector` application as a single replica. It includes probes for liveness, readiness, and startup to ensure the application is healthy and operational.

### ConfigMaps
1. **Name**: `reflector-values-hk2hfcmmh5`
   - **Namespace**: `flux-system`
   - **Purpose**: Provides Helm values for the `reflector` HelmRelease, including tolerations, Kubernetes configuration, and logging settings.

2. **Name**: `reflector-config`
   - **Namespace**: `reflector`
   - **Purpose**: Contains the logging configuration for the `reflector` application in JSON format.

## Configuration Highlights

- **Image**: `emberstack/kubernetes-reflector:7.1.262`
- **Replicas**: `1`
- **Probes**:
  - Liveness, readiness, and startup probes are configured to monitor the `/healthz` endpoint on port `25080`.
- **Security Context**:
  - Drops all capabilities.
  - Does not enforce running as a non-root user.
  - `runAsUser`: `0`
- **Tolerations**:
  - Allows scheduling on nodes with the `CriticalAddonsOnly` taint.
- **Environment Variables**:
  - `ES_Serilog__MinimumLevel__Default`: `Information`
  - `ES_Reflector__Kubernetes__SkipTlsVerify`: `true`
- **Volumes**:
  - Mounts the `reflector-config` ConfigMap to `/app/reflector.logging.json` in the container.

## Deployment

- **Target Namespace**: `reflector`
- **Release Name**: `reflector`
- **Reconciliation Interval**: `10m`
- **Install/Upgrade Behavior**:
  - Unlimited retries for remediation during installation.
  - Post-rendering patches applied to the Deployment to add volume mounts and annotations. 

This deployment ensures that the `reflector` application is consistently reconciled and operational, providing a reliable mechanism for synchronizing ConfigMaps and Secrets across namespaces.
