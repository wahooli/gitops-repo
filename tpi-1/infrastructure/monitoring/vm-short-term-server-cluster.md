---
title: "vm-short-term-server-cluster"
parent: "Infrastructure / Monitoring"
grand_parent: "tpi-1"
---

# vm-short-term-server-cluster

## Overview

The `vm-short-term-server-cluster` component deploys a short-term storage cluster for VictoriaMetrics, a high-performance, cost-effective monitoring solution. This deployment is optimized for storing metrics with a retention period of one month. It is part of the monitoring infrastructure in the `tpi-1` cluster and is managed using Flux and Helm.

## Dependencies

This component depends on the `victoria-metrics--victoria-metrics-operator` HelmRelease, which provides the operator necessary for managing VictoriaMetrics clusters. The operator ensures the proper functioning and lifecycle management of the VictoriaMetrics cluster components.

## Helm Chart(s)

- **Chart Name**: `victoria-metrics-cluster`
- **Repository**: [VictoriaMetrics Helm Charts](https://victoriametrics.github.io/helm-charts/)
- **Version**: `0.16.1`

## Resource Glossary

### Networking
- **Services**:
  - `vminsert-short-term-tpi-1-server`: Exposes the `vminsert` component on port `8480` for HTTP traffic.
  - `vmstorage-short-term-tpi-1-server`: Exposes the `vmstorage` component on ports `8482` (HTTP), `8400` (vminsert), and `8401` (vmselect). This service is headless (`ClusterIP: None`) to support StatefulSet communication.

### Workloads
- **Deployment**:
  - `vminsert-short-term-tpi-1-server`: Handles incoming metrics ingestion. Configured with one replica and readiness/liveness probes for health monitoring.
- **StatefulSet**:
  - `vmstorage-short-term-tpi-1-server`: Manages the storage backend for metrics. Configured with one replica and persistent storage.

### Security
- **ServiceAccount**:
  - `victoria-metrics-server-short-term`: Used by the VictoriaMetrics components for secure access to Kubernetes resources.

### Configuration
- **ConfigMap**:
  - `victoria-metrics-server-short-term-values-58748g4tmk`: Provides custom Helm values for configuring the VictoriaMetrics cluster.

## Configuration Highlights

- **Retention Period**: Metrics are retained for one month (`retentionPeriod: "1"`).
- **Persistence**:
  - `vmstorage` uses a persistent volume with a size of `6Gi`.
- **Replica Counts**:
  - `vminsert`: 1 replica.
  - `vmstorage`: 1 replica.
- **Images**:
  - `vminsert`: `victoriametrics/vminsert:v1.137.0-cluster`
  - `vmstorage`: `victoriametrics/vmstorage:v1.137.0-cluster`
- **Node Affinity and Tolerations**:
  - Both `vminsert` and `vmstorage` are scheduled on control-plane nodes using specific tolerations and node affinity rules.
- **Global Service Annotations**:
  - Services are annotated for global synchronization using Cilium (`service.cilium.io/global: "true"`).

## Deployment

- **Target Namespace**: `monitoring`
- **Release Name**: `victoria-metrics-server-short-term`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: Unlimited retries on installation failure (`retries: -1`).

This deployment is managed by Flux and uses a HelmRelease to ensure the desired state is maintained. Configuration values are sourced from two ConfigMaps, allowing for flexible and centralized management of settings.
