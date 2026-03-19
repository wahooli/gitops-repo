---
title: "reflector"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# Reflector

## Overview

The `reflector` component is a Kubernetes deployment that synchronizes ConfigMaps and Secrets across namespaces. It is designed to simplify the management of shared configuration and secrets in multi-namespace Kubernetes clusters. This component is deployed using a Helm chart from the Emberstack Helm repository.

## Helm Chart(s)

- **Chart Name**: `reflector`
- **Repository**: [Emberstack Helm Charts](https://emberstack.github.io/helm-charts)
- **Version**: `7.1.262`

## Resource Glossary

### Namespace
- **Name**: `reflector`
- **Purpose**: Provides an isolated namespace for the `reflector` component and its associated resources.

### ServiceAccount
- **Name**: `reflector`
- **Purpose**: Grants the `reflector` Deployment the necessary permissions to interact with Kubernetes resources.

### ClusterRole
- **Name**: `reflector`
- **Purpose**: Defines permissions for the `reflector` component to manage ConfigMaps, Secrets, and watch namespaces.

### ClusterRoleBinding
- **Name**: `reflector`
- **Purpose**: Binds the `reflector` ServiceAccount to the `reflector` ClusterRole, enabling it to perform the actions defined in the role.

### Deployment
- **Name**: `reflector`
- **Purpose**: Runs the `reflector` application as a single replica. The deployment ensures high availability and manages the lifecycle of the application.

  - **Container Image**: `emberstack/kubernetes-reflector:7.1.262`
  - **Ports**: 
    - `25080/TCP` for HTTP traffic.
  - **Probes**:
    - Liveness, readiness, and startup probes are configured to ensure the application is running and healthy.
  - **Security Context**:
    - Drops all capabilities.
    - Does not enforce running as a non-root user.
    - Filesystem is not read-only.
  - **Tolerations**:
    - Allows scheduling on nodes with the `CriticalAddonsOnly` taint.

### ConfigMaps
1. **Name**: `reflector-values-hk2hfcmmh5`
   - **Purpose**: Provides Helm values for the `reflector` HelmRelease.
   - **Key Configuration**:
     - Tolerations for scheduling.
     - Kubernetes TLS verification is skipped.
     - Logging level is set to `Information`.
     - Security context settings for the container.

2. **Name**: `reflector-config`
   - **Purpose**: Contains the logging configuration for the `reflector` application.
   - **Key Configuration**:
     - Uses Serilog for structured logging.
     - Logs are written to the console with a specific output template.
     - Overrides logging levels for specific namespaces like `Microsoft` and `System`.

## Configuration Highlights

- **Logging**:
  - Minimum logging level is set to `Information`.
  - Custom logging configuration is provided via the `reflector-config` ConfigMap.
- **Security Context**:
  - Drops all capabilities for the container.
  - Does not enforce running as a non-root user.
  - Filesystem is not read-only.
- **Kubernetes TLS**:
  - Skips TLS verification for Kubernetes API interactions.
- **Probes**:
  - Liveness, readiness, and startup probes are configured to monitor application health.
- **Tolerations**:
  - Configured to allow scheduling on nodes with the `CriticalAddonsOnly` taint.

## Deployment

- **Target Namespace**: `reflector`
- **Release Name**: `reflector`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**:
  - Unlimited retries for failed installations or upgrades.
  - Post-rendering patches are applied to the Deployment to add volume mounts and annotations.

This deployment ensures that the `reflector` component is consistently reconciled and operational in the `tpi-1` cluster.
