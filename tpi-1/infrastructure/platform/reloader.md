---
title: "reloader"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# Reloader

## Overview

The `reloader` component is a Kubernetes utility that automatically reloads deployments, statefulsets, and daemonsets when their associated ConfigMaps or Secrets are updated. This ensures that applications using these resources are always running with the latest configurations or secrets without requiring manual intervention. It is deployed in the `tpi-1` cluster using the Stakater Helm chart.

## Helm Chart(s)

### HelmRelease: `reloader--reloader`
- **Chart Name**: `reloader`
- **Chart Version**: `1.0.121`
- **Repository**: [Stakater Helm Charts](https://stakater.github.io/stakater-charts)
- **Release Name**: `reloader`
- **Target Namespace**: `reloader`
- **Reconciliation Interval**: 2 minutes

## Resource Glossary

The `reloader` component creates the following Kubernetes resources:

### Security
- **ServiceAccount**: A dedicated service account named `reloader` in the `reloader` namespace. This is used by the `reloader` deployment to interact with Kubernetes resources securely.

- **ClusterRole**: A cluster-wide role named `reloader-role` that grants permissions to list, get, watch, update, and patch ConfigMaps, Secrets, Deployments, DaemonSets, StatefulSets, and other related resources.

- **ClusterRoleBinding**: A binding named `reloader-role-binding` that associates the `reloader-role` with the `reloader` service account, enabling it to perform its operations.

### Workload
- **Deployment**: A single replica deployment named `reloader` in the `reloader` namespace. This deployment runs the `reloader` application using the `ghcr.io/stakater/reloader:v1.0.121` image.

  - **Probes**:
    - Liveness Probe: Checks the `/live` endpoint on port `9090` to ensure the container is running.
    - Readiness Probe: Checks the `/metrics` endpoint on port `9090` to ensure the container is ready to serve traffic.

  - **Security Context**:
    - Runs as a non-root user with UID `65534`.
    - Uses a `RuntimeDefault` seccomp profile.

  - **Resource Requests and Limits**:
    - CPU: `10m` (request), `150m` (limit)
    - Memory: `128Mi` (request), `512Mi` (limit)

  - **Environment Variables**:
    - `GOMAXPROCS`: Automatically set based on CPU limits.
    - `GOMEMLIMIT`: Automatically set based on memory limits.

  - **Command-line Arguments**:
    - `--log-format=json`: Configures the application to use JSON log formatting.
    - `--namespaces-to-ignore`: Excludes specific namespaces from being monitored for ConfigMap or Secret changes. Ignored namespaces include:
      - `flux-system`
      - `cilium-secrets`
      - `kube-system`
      - `kube-node-lease`
      - `kube-public`
      - `openebs`
      - `velero`
      - `reflector`

### Namespace
- **Namespace**: A dedicated namespace named `reloader` is created to isolate the resources for this component.

## Configuration Highlights

- **Resource Requests and Limits**:
  - CPU: `10m` (request), `150m` (limit)
  - Memory: `128Mi` (request), `512Mi` (limit)

- **Replica Count**: The deployment runs with a single replica. High availability is not enabled (`enableHA: false`).

- **Ignored Namespaces**: The `reloader` component is configured to ignore updates in specific namespaces, such as `flux-system`, `kube-system`, and others, to avoid unnecessary reloads in critical or system namespaces.

- **Logging**: Logs are formatted in JSON for easier integration with log aggregation and analysis tools.

- **Security**: The deployment adheres to Kubernetes security best practices by running as a non-root user and using a `RuntimeDefault` seccomp profile.

## Deployment

- **Target Namespace**: `reloader`
- **Release Name**: `reloader`
- **Reconciliation Interval**: Every 2 minutes
- **Install/Upgrade Behavior**:
  - Unlimited retries for failed installations (`retries: -1`).
  - Installation timeout set to 5 minutes.
