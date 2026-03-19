---
title: "monitoring resources"
parent: "Infrastructure / Monitoring"
grand_parent: "tpi-1"
---

## Overview

The `monitoring` infrastructure layer for cluster `tpi-1` is designed to manage and monitor metrics efficiently using VictoriaMetrics components. This setup includes resources for scraping metrics, storing data, and providing authentication and proxying capabilities for read and write operations. The components work together to ensure high availability, scalability, and optimized data retention for monitoring workloads.

## Resource Glossary

### VMAgent (`vmagent.yaml`)
- **Kind**: `VMAgent`
- **Name**: `tpi-1`
- **Namespace**: `monitoring`
- **Purpose**: The `VMAgent` is responsible for scraping metrics from various sources and forwarding them to multiple remote write endpoints for storage and processing.
- **Details**:
  - Scrapes metrics at a 30-second interval and forwards them to configured endpoints.
  - Applies relabeling rules to filter and modify metrics before sending them.
  - Configured with external labels to identify the cluster (`clustername: tpi-1`).
  - Uses resource limits and requests to manage CPU and memory usage.
  - Provides a service with `ClusterIP` type and annotations for Cilium service configuration.
  - Includes affinity rules to avoid scheduling on control-plane nodes.

### VMAuth (`vmauth.global-write.yaml`)
- **Kind**: `VMAuth`
- **Name**: `global-write`
- **Namespace**: `monitoring`
- **Purpose**: The `VMAuth` resource acts as an authentication and proxy layer for write operations to VictoriaMetrics components.
- **Details**:
  - Configured to listen on port `8427`.
  - Provides a `ClusterIP` service with annotations for Cilium service configuration.
  - Defines URL mappings for unauthenticated user access to write endpoints, with retry policies for specific HTTP status codes (`502`, `503`, `504`).
  - Routes traffic to `vmagent-tpi-1` and `vmagent-nas` services.

### VMAuth (`vmauth.read-proxy.yaml`)
- **Kind**: `VMAuth`
- **Name**: `read-proxy`
- **Namespace**: `monitoring`
- **Purpose**: The `VMAuth` resource acts as an authentication and proxy layer for read operations from VictoriaMetrics components.
- **Details**:
  - Configured to listen on port `8427`.
  - Defines URL mappings for unauthenticated user access to read endpoints, with retry policies for HTTP status code `503`.
  - Routes traffic to `vmclusterlb-short-term-tpi-1`, `vmselect-short-term-nas-0`, and `vmselect-short-term-nas-1` services.

### VMCluster (`vmcluster.yaml`)
- **Kind**: `VMCluster`
- **Name**: `short-term-tpi-1`
- **Namespace**: `monitoring`
- **Purpose**: The `VMCluster` resource manages the VictoriaMetrics cluster for short-term data storage and retrieval.
- **Details**:
  - Configured with a retention period of 6 months and a replication factor of 2 for high availability.
  - Includes components for data insertion (`vminsert`), storage (`vmstorage`), and querying (`vmselect`).
  - Provides a load balancer for handling requests, with affinity rules to optimize scheduling.
  - Each component (`vminsert`, `vmstorage`, `vmselect`) is configured with resource limits, affinity rules, and storage specifications:
    - **VMInsert**: Handles data ingestion and forwards it to storage nodes.
    - **VMStorage**: Stores metrics data with a `35Gi` persistent volume per replica.
    - **VMSelect**: Handles query operations and connects to storage nodes.
  - Uses `ClusterIP` services with annotations for Cilium service configuration.
