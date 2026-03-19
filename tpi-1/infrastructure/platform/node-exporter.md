---
title: "node-exporter"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# Node Exporter

## Overview

The `node-exporter` component is responsible for exposing hardware and OS-level metrics from Kubernetes nodes. These metrics are collected by Prometheus and used for monitoring and alerting purposes. It is deployed as a DaemonSet to ensure that an instance runs on every node in the cluster.

## Dependencies

This component has a dependency on the `prometheus-operator-crds` HelmRelease. This dependency ensures that the necessary Custom Resource Definitions (CRDs) for Prometheus are available before deploying the `node-exporter`.

## Helm Chart(s)

- **Chart Name**: `prometheus-node-exporter`
- **Repository**: [prometheus-community](https://prometheus-community.github.io/helm-charts)
- **Version**: 4.52.0

## Resource Glossary

### Networking
- **Service**: 
  - Name: `node-exporter`
  - Type: `ClusterIP`
  - Port: `9100`
  - Purpose: Exposes the metrics endpoint (`/metrics`) for Prometheus to scrape.

### Workload
- **DaemonSet**:
  - Name: `node-exporter`
  - Ensures that a `node-exporter` pod runs on every node in the cluster.
  - Uses the `quay.io/prometheus/node-exporter:v1.10.2` container image.
  - Configured with host networking and host PID namespace for direct access to node-level metrics.
  - Includes liveness and readiness probes to ensure the health of the `node-exporter` pods.

### Security
- **ServiceAccount**:
  - Name: `node-exporter`
  - Does not allow the automatic mounting of service account tokens for enhanced security.

### Configuration
- **ConfigMap**:
  - Name: `node-exporter-values-4mc8f9t49f`
  - Contains additional Helm values for customizing the deployment, such as ignored filesystem types and mount points.

## Configuration Highlights

- **Extra Arguments**:
  - Excludes specific filesystem mount points and network devices from being collected to reduce noise in the metrics.
  - Disables collectors for `xfs`, `tapestats`, `infiniband`, `bonding`, and `bcache` to optimize performance.
  - Configures logging in JSON format for better integration with log aggregation systems.

- **Security Context**:
  - Runs as a non-root user (`65534`) with a read-only root filesystem for enhanced security.

- **Node Affinity and Tolerations**:
  - Ensures the `node-exporter` pods are scheduled only on Linux nodes and excludes certain node types like Fargate and virtual-kubelet.

- **Volumes**:
  - Mounts host paths (`/proc`, `/sys`, `/`) to access node-level metrics.

## Deployment

- **Target Namespace**: `kube-system`
- **Release Name**: `node-exporter`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: Unlimited retries on installation failures, ensuring the component is deployed successfully.
