---
title: "vlogs-short-term"
parent: "Infrastructure / Logging"
grand_parent: "tpi-1"
---

# vlogs-short-term

## Overview

The `vlogs-short-term` component is a logging solution deployed in the `tpi-1` cluster. It uses VictoriaMetrics' `victoria-logs-single` Helm chart to provide a scalable and efficient log storage and querying system. This deployment is optimized for short-term log retention and is configured to store logs for up to 100 years with a maximum disk space usage of 14 GiB per replica.

## Dependencies

This component depends on the `victoria-metrics--victoria-metrics-operator` HelmRelease, which provides operator-level functionality for managing VictoriaMetrics resources within the cluster.

## Helm Chart(s)

### HelmRelease: `logging--victoria-logs-short-term`
- **Chart Name**: `victoria-logs-single`
- **Version**: `0.11.28`
- **Repository**: [VictoriaMetrics Helm Charts](https://victoriametrics.github.io/helm-charts/)
- **Release Name**: `victoria-logs-short-term`
- **Target Namespace**: `logging`
- **Reconciliation Interval**: 10 minutes

## Resource Glossary

### Networking
- **Service**: 
  - Name: `vlogs-short-term-tpi-1`
  - Type: `ClusterIP`
  - Port: `9428` (HTTP)
  - Annotations:
    - `service.cilium.io/global`: `"true"`
    - `service.cilium.io/global-sync-endpoint-slices`: `"true"`
    - `service.cilium.io/affinity`: `"local"`
  - Purpose: Provides internal cluster access to the VictoriaMetrics logs server.

### Storage
- **PersistentVolumeClaim**:
  - Name: `server-volume`
  - Size: `15Gi`
  - Access Mode: `ReadWriteOnce`
  - Purpose: Stores log data for the StatefulSet pods.

### Workload
- **StatefulSet**:
  - Name: `vlogs-short-term-tpi-1`
  - Replicas: `2`
  - Pod Labels:
    - `app: server`
    - `app.kubernetes.io/instance: victoria-logs-short-term`
    - `app.kubernetes.io/name: victoria-logs-single`
  - Security Context:
    - `fsGroup: 2000`
    - `runAsNonRoot: true`
    - `runAsUser: 1000`
  - Container:
    - Name: `vlogs`
    - Image: `victoriametrics/victoria-logs:v1.24.0-victorialogs`
    - Pull Policy: `IfNotPresent`
    - Ports: `9428` (HTTP)
    - Arguments:
      - `--retention.maxDiskSpaceUsageBytes=14336MiB`
      - `--retentionPeriod=100y`
      - `--storageDataPath=/storage`
    - Probes:
      - Readiness Probe: HTTP GET `/health` on port `http`
      - Liveness Probe: TCP socket check on port `http`
    - Volume Mounts:
      - `/storage` mounted to `server-volume`
  - Affinity:
    - Node Affinity: Avoids scheduling on control-plane nodes.
    - Pod Anti-Affinity: Prefers spreading pods across nodes to avoid co-locating with `vmstorage` pods.
  - Termination Grace Period: 60 seconds

### Monitoring
- **VMServiceScrape**:
  - Name: `vlogs-short-term-tpi-1`
  - Namespace: `logging`
  - Endpoints:
    - Path: `/metrics`
    - Port: `http`
  - Selector:
    - Labels:
      - `app: server`
      - `app.kubernetes.io/instance: victoria-logs-short-term`
  - Purpose: Configures service scraping for metrics collection.

### Image Management
- **ImageRepository**:
  - Name: `victoria-logs-single`
  - Repository: `ghcr.io/victoriametrics/helm-charts/victoria-logs-single`
  - Interval: 24 hours
  - Purpose: Tracks the Helm chart image repository.
- **ImageRepository**:
  - Name: `victoria-logs`
  - Repository: `victoriametrics/victoria-logs`
  - Interval: 24 hours
  - Purpose: Tracks the VictoriaMetrics logs server image repository.
- **ImagePolicy**:
  - Name: `victoria-logs-single`
  - Policy: Semantic versioning (`x.x.x`)
  - Purpose: Ensures the Helm chart image is up-to-date.
- **ImagePolicy**:
  - Name: `victoria-logs`
  - Policy: Semantic versioning (`x.x.x`) with tag filtering for versions matching `vX.X.X-victorialogs`.
  - Purpose: Ensures the VictoriaMetrics logs server image is up-to-date.

## Configuration Highlights

- **Replica Count**: `2` for high availability.
- **Retention Period**: Logs are retained for up to `100 years`.
- **Disk Space Usage**: Maximum of `14 GiB` per replica.
- **Persistent Storage**: Enabled with a volume size of `15 GiB`.
- **Affinity Rules**:
  - Avoids control-plane nodes.
  - Spreads pods across nodes to reduce contention with `vmstorage` pods.
- **Service Annotations**: Configured for global access and local affinity using Cilium.

## Deployment

- **Target Namespace**: `logging`
- **Release Name**: `victoria-logs-short-term`
- **Reconciliation Interval**: 10 minutes
- **Install Behavior**: Unlimited retries for remediation during installation.
