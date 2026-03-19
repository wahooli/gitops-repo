---
title: "reloader"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# Reloader

## Overview

Reloader is a Kubernetes utility designed to automatically reload deployments, daemonsets, and statefulsets when their associated ConfigMaps or Secrets are updated. This ensures that applications can seamlessly adapt to configuration changes without manual intervention. In the `livingroom-pi` cluster, Reloader is deployed using the Stakater Helm chart.

## Helm Chart(s)

### HelmRelease: `reloader--reloader`
- **Chart Name**: `reloader`
- **Version**: `1.0.121`
- **Repository**: [Stakater Helm Charts](https://stakater.github.io/stakater-charts)
- **Release Name**: `reloader`
- **Target Namespace**: `reloader`
- **Reconciliation Interval**: `2m`

## Resource Glossary

### Namespace
- **Name**: `reloader`
- **Purpose**: Provides a dedicated namespace for the Reloader component to isolate its resources from other components in the cluster.

### HelmRepository
- **Name**: `stakater`
- **Namespace**: `flux-system`
- **Purpose**: Defines the source for the Stakater Helm charts repository, enabling the deployment of the Reloader Helm chart.

### HelmRelease
- **Name**: `reloader--reloader`
- **Namespace**: `flux-system`
- **Purpose**: Manages the installation and lifecycle of the Reloader Helm chart in the `reloader` namespace.

### ConfigMap
- **Name**: `reloader-values-kdgb5662hk`
- **Namespace**: `flux-system`
- **Purpose**: Provides custom values for the Reloader Helm chart, including operational settings such as ignored namespaces, resource limits, and logging format.

### ServiceAccount
- **Name**: `reloader`
- **Namespace**: `reloader`
- **Purpose**: Grants permissions for the Reloader deployment to interact with Kubernetes resources such as ConfigMaps and Secrets.

### ClusterRole
- **Name**: `reloader-role`
- **Purpose**: Defines permissions for Reloader to list, get, watch, update, and patch various Kubernetes resources, including deployments, daemonsets, statefulsets, secrets, and ConfigMaps.

### ClusterRoleBinding
- **Name**: `reloader-role-binding`
- **Purpose**: Binds the `reloader-role` ClusterRole to the `reloader` ServiceAccount, enabling Reloader to perform its operations cluster-wide.

### Deployment
- **Name**: `reloader`
- **Namespace**: `reloader`
- **Purpose**: Deploys the Reloader application as a single replica. The deployment includes probes for liveness and readiness, ensuring the application's health and operational status.

#### Key Deployment Details:
- **Image**: `ghcr.io/stakater/reloader:v1.0.121`
- **Replicas**: `1`
- **Resource Requests**: 
  - CPU: `10m`
  - Memory: `128Mi`
- **Resource Limits**:
  - CPU: `150m`
  - Memory: `512Mi`
- **Security Context**:
  - Runs as a non-root user (`65534`).
  - Seccomp profile set to `RuntimeDefault`.
- **Probes**:
  - Liveness Probe: Checks `/live` endpoint.
  - Readiness Probe: Checks `/metrics` endpoint.

## Configuration Highlights

### Notable Helm Values
- **Ignored Namespaces**: `flux-system,cilium-secrets,kube-system,kube-node-lease,kube-public,kube-system,openebs,velero,reflector`
- **Log Format**: `json`
- **Resource Requests and Limits**:
  - Requests: CPU `10m`, Memory `128Mi`
  - Limits: CPU `150m`, Memory `512Mi`
- **Replica Count**: `1`
- **ServiceAccount**: Automatically created and used by the deployment.

### Environment Variables
- **GOMAXPROCS**: Dynamically set based on CPU limits.
- **GOMEMLIMIT**: Dynamically set based on memory limits.

### Operational Features
- Leadership election is disabled (`enableHA: false`).
- Watches globally across all namespaces unless explicitly ignored.
- Reload strategy set to `default`.

## Deployment

- **Target Namespace**: `reloader`
- **Release Name**: `reloader`
- **Reconciliation Interval**: `2m`
- **Install Behavior**: Unlimited retries on failure (`retries: -1`).
- **Upgrade Behavior**: HelmRelease automatically reconciles changes every 2 minutes.

This deployment ensures that configuration changes are automatically propagated to workloads, reducing manual intervention and improving operational efficiency.
