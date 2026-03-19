---
title: "smartctl-exporter"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# smartctl-exporter

## Overview
The `smartctl-exporter` component is a Prometheus exporter designed to monitor the health of storage devices using the `smartctl` utility. It is deployed as a DaemonSet to ensure that the exporter runs on each node in the Kubernetes cluster. This component is part of the monitoring stack and provides metrics about the health and status of storage devices, which can be scraped by Prometheus for alerting and visualization.

## Dependencies
This component has a dependency on the `prometheus-operator-crds` HelmRelease. This dependency ensures that the necessary Custom Resource Definitions (CRDs) for Prometheus are installed and available before deploying the `smartctl-exporter`.

## Helm Chart(s)
- **Chart Name**: `prometheus-smartctl-exporter`
- **Repository**: [prometheus-community](https://prometheus-community.github.io/helm-charts)
- **Version**: 0.16.0

## Resource Glossary
The `smartctl-exporter` component creates the following Kubernetes resources:

### Networking
- **Service**: 
  - Name: `smartctl-exporter`
  - Type: `ClusterIP`
  - Port: `80` (mapped to container port `9633` for HTTP metrics endpoint)
  - Purpose: Exposes the metrics endpoint (`/metrics`) for Prometheus to scrape.

### Workload
- **DaemonSet**: 
  - Name: `smartctl-exporter-0`
  - Purpose: Ensures that the `smartctl-exporter` runs on all nodes in the cluster.
  - Container:
    - **Image**: `quay.io/prometheuscommunity/smartctl-exporter:v0.14.0`
    - **Args**:
      - `--smartctl.path=/usr/sbin/smartctl`
      - `--smartctl.interval=120s`
      - `--smartctl.device-include=sd.*|nvme.*`
      - `--web.listen-address=0.0.0.0:9633`
      - `--web.telemetry-path=/metrics`
    - **Security Context**: Runs as a privileged container with `runAsUser: 0`.
    - **Volumes**:
      - Mounts `/dev` from the host to `/hostdev` in the container for accessing storage devices.

### Security
- **ServiceAccount**:
  - Name: `smartctl-exporter`
  - Purpose: Provides an identity for the `smartctl-exporter` DaemonSet to interact with the Kubernetes API.
- **RoleBinding**:
  - Name: `smartctl-exporter`
  - Purpose: Grants the `smartctl-exporter` ServiceAccount permissions to use the `unrestricted-psp` ClusterRole.

### Configuration
- **ConfigMap**:
  - Name: `smartctl-exporter-values-64c6g7g48b`
  - Purpose: Stores additional Helm values for the `smartctl-exporter` configuration.
  - Key settings:
    - `config.device_include`: Regex pattern to include devices (`sd.*|nvme.*`).
    - `common.config`: Configures the exporter to bind to `0.0.0.0:9633` and expose metrics at `/metrics`.
    - `serviceMonitor.enabled`: Disabled by default.
    - `image.repository`: `quay.io/prometheuscommunity/smartctl-exporter`.
    - `image.tag`: Defaults to `v0.14.0` (inherited from the chart's appVersion).
    - `service.type`: `ClusterIP`.

## Configuration Highlights
- **Device Inclusion**: The exporter is configured to monitor devices matching the regex `sd.*|nvme.*`.
- **Metrics Endpoint**: Metrics are exposed on port `9633` at the `/metrics` path.
- **Security Context**: The container runs as a privileged user (`runAsUser: 0`) to access storage device details.
- **Tolerations**: Configured to allow scheduling on nodes with `NoSchedule` taints.

## Deployment
- **Target Namespace**: `kube-system`
- **Release Name**: `smartctl-exporter`
- **Reconciliation Interval**: Every 10 minutes
- **Install/Upgrade Behavior**: Unlimited retries for failed installations or upgrades.

This deployment ensures that the `smartctl-exporter` is consistently reconciled and running on all nodes in the cluster, providing critical storage health metrics for monitoring and alerting purposes.
