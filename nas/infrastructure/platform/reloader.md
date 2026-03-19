---
title: "reloader"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# Reloader

## Overview

Reloader is a Kubernetes utility designed to automatically reload deployments, daemonsets, and statefulsets when their associated ConfigMaps or Secrets are updated. This ensures that applications using these resources can dynamically adapt to configuration changes without manual intervention. In the `nas` cluster, Reloader is deployed using Flux GitOps and Helm.

## Helm Chart(s)

### HelmRelease: `reloader--reloader`
- **Chart Name**: `reloader`
- **Version**: `1.0.121`
- **Repository**: [Stakater Charts](https://stakater.github.io/stakater-charts)
- **Release Name**: `reloader`
- **Target Namespace**: `reloader`
- **Reconciliation Interval**: `2m`

## Resource Glossary

### Namespace
- **Name**: `reloader`
- **Purpose**: Provides an isolated namespace for Reloader resources, ensuring clean separation from other components in the cluster.

### HelmRepository
- **Name**: `stakater`
- **URL**: `https://stakater.github.io/stakater-charts`
- **Purpose**: Defines the source repository for the Reloader Helm chart, enabling automated chart updates every 24 hours.

### HelmRelease
- **Name**: `reloader--reloader`
- **Purpose**: Manages the deployment of the Reloader Helm chart in the `reloader` namespace, ensuring reconciliation and updates based on the specified chart version and values.

### ConfigMap
- **Name**: `reloader-values-kdgb5662hk`
- **Purpose**: Stores custom Helm values for configuring the Reloader deployment, including ignored namespaces, logging format, and resource limits.

### ServiceAccount
- **Name**: `reloader`
- **Purpose**: Provides Reloader with a dedicated service account for interacting with Kubernetes resources securely.

### ClusterRole
- **Name**: `reloader-role`
- **Purpose**: Grants Reloader permissions to list, get, watch, update, and patch ConfigMaps, Secrets, and workloads (Deployments, DaemonSets, StatefulSets, CronJobs, and Jobs).

### ClusterRoleBinding
- **Name**: `reloader-role-binding`
- **Purpose**: Binds the `reloader-role` to the `reloader` ServiceAccount, enabling Reloader to perform its operations across the cluster.

### Deployment
- **Name**: `reloader`
- **Replicas**: `1`
- **Purpose**: Deploys the Reloader application as a single replica, responsible for monitoring and reloading workloads based on ConfigMap and Secret changes.
- **Container**:
  - **Image**: `ghcr.io/stakater/reloader:v1.0.121`
  - **Ports**: `9090` (HTTP)
  - **Probes**:
    - **Liveness**: Monitors `/live` endpoint to ensure the container is healthy.
    - **Readiness**: Monitors `/metrics` endpoint to verify the container is ready to serve traffic.
  - **Security Context**:
    - Runs as a non-root user (`65534`).
    - Uses a `RuntimeDefault` seccomp profile for enhanced security.

## Configuration Highlights

### Resource Requests and Limits
- **CPU**:
  - **Requests**: `10m`
  - **Limits**: `150m`
- **Memory**:
  - **Requests**: `128Mi`
  - **Limits**: `512Mi`

### Helm Values
- **Ignored Namespaces**: `flux-system, cilium-secrets, kube-system, kube-node-lease, kube-public, openebs, velero, reflector`
- **Log Format**: `json`
- **Replica Count**: `1`
- **ServiceAccount Creation**: Enabled

### Environment Variables
- **GOMAXPROCS**: Dynamically set based on CPU limits.
- **GOMEMLIMIT**: Dynamically set based on memory limits.

## Deployment

- **Target Namespace**: `reloader`
- **Release Name**: `reloader`
- **Reconciliation Interval**: `2m`
- **Install Behavior**: Retries indefinitely on failure.
- **Upgrade Behavior**: Retains up to 2 revision histories for rollbacks.

Reloader is configured to monitor ConfigMaps and Secrets globally across the cluster, except for specified ignored namespaces. It uses a default reload strategy and operates with minimal resource consumption, making it suitable for lightweight deployments.
