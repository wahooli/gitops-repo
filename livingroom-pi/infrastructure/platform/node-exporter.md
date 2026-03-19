---
title: "node-exporter"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# node-exporter

## Overview

The `node-exporter` component is responsible for exposing hardware and OS-level metrics from Kubernetes nodes. These metrics are used by Prometheus for monitoring and alerting purposes. The `node-exporter` is deployed as a DaemonSet, ensuring that each node in the cluster runs an instance of the exporter. This deployment is managed using Flux and Helm.

## Dependencies

The `node-exporter` component has a dependency on the `prometheus-operator--prometheus-operator-crds` HelmRelease. This dependency ensures that the necessary Custom Resource Definitions (CRDs) for Prometheus are available before deploying the `node-exporter`.

## Helm Chart(s)

- **Chart Name:** `prometheus-node-exporter`
- **Repository:** [prometheus-community](https://prometheus-community.github.io/helm-charts)
- **Version:** 4.52.0

## Resource Glossary

### Networking
- **Service (`node-exporter`)**: Exposes the metrics endpoint on port `9100` using a `ClusterIP` service. The service is labeled with `jobLabel: node-exporter` to integrate with Prometheus ServiceMonitors.

### Workload
- **DaemonSet (`node-exporter`)**: Ensures that a `node-exporter` pod runs on every node in the cluster. The pods collect and expose metrics from the node's hardware and OS.

### Security
- **ServiceAccount (`node-exporter`)**: A dedicated ServiceAccount is created for the `node-exporter` pods. The `automountServiceAccountToken` is set to `false` for enhanced security.

### Configuration
- **ConfigMap (`node-exporter-values-4mc8f9t49f`)**: Contains additional configuration values for the Helm chart, such as:
  - `extraArgs` for excluding specific filesystem mount points and network devices from monitoring.
  - `service.labels` to add a `jobLabel` for Prometheus integration.

### Image Management
- **ImageRepository (`prometheus-node-exporter`)**: Tracks the container image for the `node-exporter` from `ghcr.io/prometheus-community/charts/prometheus-node-exporter`.
- **ImagePolicy (`prometheus-node-exporter`)**: Ensures the image follows a semantic versioning (`x.x.x`) policy.

## Configuration Highlights

- **DaemonSet Configuration:**
  - Pods run with `hostNetwork: true`, `hostPID: true`, and `hostIPC: false`.
  - Security context ensures the pods run as non-root (`runAsNonRoot: true`) with a read-only root filesystem.
  - Node affinity rules prevent deployment on Fargate or virtual-kubelet nodes.
  - Tolerations allow scheduling on nodes with `NoSchedule` taints.

- **Metrics Collection:**
  - Metrics are exposed on port `9100`.
  - Specific filesystem mount points and network devices are excluded from monitoring using `--collector.filesystem.mount-points-exclude`, `--collector.ethtool.device-exclude`, and `--collector.netdev.device-exclude`.
  - Certain collectors (e.g., `xfs`, `tapestats`, `infiniband`, `bonding`, `bcache`) are disabled using `--no-collector` flags.
  - Metrics are exposed in JSON format (`--log.format=json`).

- **Volumes:**
  - Host paths `/proc`, `/sys`, and `/` are mounted into the container for accessing node-level metrics.

## Deployment

- **Target Namespace:** `kube-system`
- **Release Name:** `node-exporter`
- **Reconciliation Interval:** 10 minutes
- **Install/Upgrade Behavior:** Unlimited retries on remediation in case of failure.
