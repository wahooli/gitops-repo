---
title: "seaweedfs"
parent: "Apps"
grand_parent: "nas"
---

# SeaweedFS

This document provides an overview of the SeaweedFS component deployed in the `nas` Kubernetes cluster using Flux and Helm. The deployment is managed via a `HelmRelease` resource and uses the `seaweedfs` Helm chart version `4.0.0` from the official [SeaweedFS Helm repository](https://seaweedfs.github.io/seaweedfs/helm).

## Overview

SeaweedFS is a distributed file system designed to handle large amounts of data with high throughput and low latency. It is deployed in the `default` namespace of the `nas` cluster.

### Helm Chart Details

- **Chart Name**: `seaweedfs`
- **Chart Version**: `4.0.0`
- **Helm Repository**: [SeaweedFS Helm Repository](https://seaweedfs.github.io/seaweedfs/helm)
- **Release Name**: `seaweedfs`
- **Namespace**: `default`
- **Values Source**: 
  - ConfigMap: `seaweedfs-values-9mc44mf4ff`
    - Keys: `values-base.yaml`, `values.yaml`

### Customizations

The deployment includes custom patches applied via Kustomize post-renderers to add the annotation `service.cilium.io/global: "true"` to the following `Service` resources:
- Services with the label `app.kubernetes.io/component=filer`
- Services with the label `app.kubernetes.io/component=s3`
- Services with the label `app.kubernetes.io/component=master`

## Components

The SeaweedFS deployment consists of the following main components:

### 1. Master Server
- **Enabled**: Yes
- **Replicas**: 1
- **Ports**:
  - HTTP: `9333`
  - gRPC: `19333`
  - Metrics: `9327`
- **Storage**:
  - Data: `hostPath` at `/ssd`
  - Logs: `hostPath` at `/storage`
- **Default Replication**: `000`
- **Liveness Probe**: Enabled
  - Path: `/cluster/status`
  - Initial Delay: 20 seconds
  - Period: 30 seconds
- **Readiness Probe**: Enabled
  - Path: `/cluster/status`
  - Initial Delay: 10 seconds
  - Period: 45 seconds

### 2. Volume Server
- **Enabled**: Yes
- **Replicas**: 1
- **Ports**:
  - HTTP: `8080`
  - gRPC: `18080`
  - Metrics: `9327`
- **Storage**:
  - Data: `hostPath` at `/ssd`
- **Read Mode**: `proxy`
- **Liveness Probe**: Enabled
  - Path: `/status`
  - Initial Delay: 20 seconds
  - Period: 90 seconds
- **Readiness Probe**: Enabled
  - Path: `/status`
  - Initial Delay: 15 seconds
  - Period: 15 seconds

### 3. Filer Server
- **Enabled**: Yes
- **Replicas**: 1
- **Ports**:
  - HTTP: `8888`
  - gRPC: `18888`
  - Metrics: `9327`
- **Storage**:
  - Data: `hostPath` at `/storage`
  - Logs: `hostPath` at `/storage`
- **Default Replica Placement**: `000`
- **Liveness Probe**: Enabled
  - Path: `/`
  - Initial Delay: 20 seconds
  - Period: 30 seconds
- **Readiness Probe**: Enabled
  - Path: `/`
  - Initial Delay: 10 seconds
  - Period: 15 seconds

### 4. S3 Gateway (Optional)
- **Enabled**: No (disabled by default)
- **Ports**:
  - HTTP: `8333`
  - HTTPS: `0` (disabled by default)

## Global Configuration

- **Image**: `chrislusf/seaweedfs`
- **Image Pull Policy**: `IfNotPresent`
- **Service Account**: `seaweedfs`
- **Replication Placement**: `001` (disabled by default)
- **Logging Level**: `1`
- **Monitoring**: Disabled

## Custom Environment Variables

The following environment variables are configured globally:
- `WEED_CLUSTER_DEFAULT`: `sw`
- `WEED_CLUSTER_SW_MASTER`: `seaweedfs-master.seaweedfs:9333`
- `WEED_CLUSTER_SW_FILER`: `seaweedfs-filer-client.seaweedfs:8888`

## Notes

- The deployment uses `hostPath` for persistent storage at `/ssd` and `/storage`. Ensure these paths are available and have sufficient capacity on the nodes.
- The deployment does not enable ingress by default. If ingress is required, it can be configured in the `values.yaml` file.
- The S3 gateway is disabled by default. Enable it in the `values.yaml` file if required.

For further customization, refer to the [SeaweedFS Helm Chart documentation](https://seaweedfs.github.io/seaweedfs/helm).
