---
title: "logging resources"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

## Overview
The logging infrastructure layer for the 'nas' cluster consists of several Kubernetes resources that manage log storage and retrieval using VictoriaMetrics. These resources include both long-term and short-term logging solutions, which are designed to handle log data efficiently. The `VLogs` resources are responsible for managing log data, while the `VLSingle` resources provide a single-instance logging solution. The `VMAuth` resource acts as an authentication proxy for accessing logs.

## Resource Glossary

### VLogs (long-term)
- **Kind**: VLogs
- **Name**: long-term-nas
- **Namespace**: logging
- **Purpose**: Manages long-term log storage.
- **Description**: This resource uses the VictoriaLogs image to store logs for up to 100 years, with a maximum disk space usage of 200GiB. It mounts a host path for storage and exposes a ClusterIP service for access.

### VLogs (short-term)
- **Kind**: VLogs
- **Name**: short-term-nas
- **Namespace**: logging
- **Purpose**: Manages short-term log storage.
- **Description**: Similar to the long-term VLogs, this resource stores logs for up to 100 years but limits the maximum disk space usage to 14848MiB. It also exposes a ClusterIP service and requests 15Gi of storage.

### VLSingle (long-term)
- **Kind**: VLSingle
- **Name**: long-term-nas
- **Namespace**: logging
- **Purpose**: Provides a single-instance long-term logging solution.
- **Description**: This resource uses the VictoriaLogs image to manage logs for up to 100 years, with a maximum disk space usage of 100GiB. It specifies resource requests for CPU and memory and mounts a host path for storage, exposing a ClusterIP service.

### VLSingle (short-term)
- **Kind**: VLSingle
- **Name**: short-term-nas
- **Namespace**: logging
- **Purpose**: Provides a single-instance short-term logging solution.
- **Description**: This resource manages logs for up to 100 years with a maximum disk space usage of 14848MiB. It requests 15Gi of storage and exposes a ClusterIP service, with specific annotations for service affinity.

### VMAuth
- **Kind**: VMAuth
- **Name**: read-proxy
- **Namespace**: logging
- **Purpose**: Acts as an authentication proxy for log access.
- **Description**: This resource listens on port 9428 and defines access rules for unauthorized users. It maps specific URL paths to various logging services, allowing for load balancing and retry mechanisms in case of service unavailability.
