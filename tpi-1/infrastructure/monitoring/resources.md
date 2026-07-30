---
title: "monitoring resources"
parent: "Infrastructure / Monitoring"
grand_parent: "tpi-1"
---

## Overview
The monitoring infrastructure layer for the cluster `tpi-1` consists of several Kubernetes resources that work together to provide a robust monitoring solution using VictoriaMetrics. These resources include agents for scraping metrics, authentication services for secure access, and a clustered storage solution for managing metrics data. The architecture is designed to ensure high availability, efficient data handling, and easy access to monitoring data.

## Resource Glossary

### VMAgent
- **Kind**: VMAgent
- **Name**: tpi-1
- **Namespace**: monitoring
- **Purpose**: The VMAgent is responsible for scraping metrics from various sources and sending them to the configured storage endpoints.
- **What it does**: It collects metrics at a specified interval (30 seconds) and writes them to multiple remote storage URLs, while applying relabeling rules to filter out unwanted data.

### VMAuth (global-write)
- **Kind**: VMAuth
- **Name**: global-write
- **Namespace**: monitoring
- **Purpose**: This resource provides authentication and access control for write operations to the monitoring system.
- **What it does**: It allows unauthenticated users to write metrics to the VMAgent by mapping specific API paths to the agent's service, handling retries for certain error codes.

### VMAuth (read-proxy)
- **Kind**: VMAuth
- **Name**: read-proxy
- **Namespace**: monitoring
- **Purpose**: This resource manages access control for read operations from the monitoring system.
- **What it does**: It routes read requests to the appropriate backend services, allowing users to query metrics while managing load balancing and retry logic for failed requests.

### VMCluster
- **Kind**: VMCluster
- **Name**: short-term-tpi-1
- **Namespace**: monitoring
- **Purpose**: The VMCluster resource defines a cluster of VictoriaMetrics components for storing and retrieving metrics data.
- **What it does**: It configures the retention period for metrics, replication factor for high availability, and specifies the storage and compute resources for the cluster components, including vminsert, vmselect, and vmstorage.

### VMStorage
- **Kind**: VMStorage (part of VMCluster)
- **Name**: short-term-tpi-1
- **Namespace**: monitoring
- **Purpose**: This component handles the storage of metrics data within the VMCluster.
- **What it does**: It manages the actual storage backend, ensuring data is stored efficiently and is accessible for querying.

### VMSelect
- **Kind**: VMSelect (part of VMCluster)
- **Name**: short-term-tpi-1
- **Namespace**: monitoring
- **Purpose**: This component is responsible for querying metrics data from the storage layer.
- **What it does**: It processes read requests and retrieves metrics data from the VMStorage instances.

### VMInsert
- **Kind**: VMInsert (part of VMCluster)
- **Name**: short-term-tpi-1
- **Namespace**: monitoring
- **Purpose**: This component is responsible for receiving incoming metrics data and writing it to the storage layer.
- **What it does**: It accepts metrics from the VMAgent and ensures they are correctly stored in the VMStorage instances.
