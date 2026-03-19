---
title: "logging resources"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

## Overview

The `logging` infrastructure layer for the `nas` cluster is responsible for managing log storage and retrieval using VictoriaMetrics components. This setup includes resources for both long-term and short-term log retention, as well as a proxy for read access to these logs. The resources are configured to optimize storage usage and provide high availability for log data.

## Resource Glossary

### VLogs: `long-term-nas`
- **Kind**: `VLogs`
- **Name**: `long-term-nas`
- **Namespace**: `logging`
- **Purpose**: This resource manages long-term log storage using the VictoriaMetrics `VLogs` operator. It is configured to store logs for up to 100 years (overridden by a disk space limit of 200GiB) and uses a hostPath volume for storage.
- **Details**:
  - Uses the `victoriametrics/victoria-logs` image with a tag managed by Flux.
  - Logs are stored in JSON format.
  - The service is exposed as a `ClusterIP` with global and local affinity annotations for Cilium.
  - Storage is mounted from a hostPath directory specified by the `${long_term_logs_cluster_directory_path}` variable.

### VLogs: `short-term-nas`
- **Kind**: `VLogs`
- **Name**: `short-term-nas`
- **Namespace**: `logging`
- **Purpose**: This resource manages short-term log storage using the VictoriaMetrics `VLogs` operator. It is configured to store logs for up to 100 years (overridden by a disk space limit of 14.5GiB) and uses a PVC for storage.
- **Details**:
  - Uses the `victoriametrics/victoria-logs` image with a tag managed by Flux.
  - Logs are stored in JSON format.
  - The service is exposed as a `ClusterIP` with global annotations for Cilium.
  - Storage is provisioned dynamically with a PVC requesting 15Gi of storage.

### VLSingle: `long-term-nas`
- **Kind**: `VLSingle`
- **Name**: `long-term-nas`
- **Namespace**: `logging`
- **Purpose**: This resource provides a single-node VictoriaMetrics instance for long-term log storage. It is configured to store logs for up to 100 years (overridden by a disk space limit of 100GiB) and uses a hostPath volume for storage.
- **Details**:
  - Uses the `victoriametrics/victoria-logs` image with a tag managed by Flux.
  - Logs are stored in JSON format.
  - The service is exposed as a `ClusterIP` with global annotations for Cilium.
  - Storage is mounted from a hostPath directory specified by the `${long_term_logs_cluster_directory_path}` variable.

### VLSingle: `short-term-nas`
- **Kind**: `VLSingle`
- **Name**: `short-term-nas`
- **Namespace**: `logging`
- **Purpose**: This resource provides a single-node VictoriaMetrics instance for short-term log storage. It is configured to store logs for up to 100 years (overridden by a disk space limit of 14.5GiB) and uses a PVC for storage.
- **Details**:
  - Uses the `victoriametrics/victoria-logs` image with a tag managed by Flux.
  - Logs are stored in JSON format.
  - The service is exposed as a `ClusterIP` with global and local affinity annotations for Cilium.
  - Storage is provisioned dynamically with a PVC requesting 15Gi of storage.

### VMAuth: `read-proxy`
- **Kind**: `VMAuth`
- **Name**: `read-proxy`
- **Namespace**: `logging`
- **Purpose**: This resource provides a proxy for read access to the log storage backends. It routes requests to the appropriate short-term log storage instances, with retry logic for unavailable backends.
- **Details**:
  - Exposes a service on port `9428`.
  - Configured with a URL map to route requests to the `short-term-nas` instances (`VLSingle` and `VLogs`).
  - Includes retry logic for HTTP 503 status codes.
  - Long-term storage (`long-term-nas`) is commented out in the configuration, indicating it is not currently used for read proxying.
