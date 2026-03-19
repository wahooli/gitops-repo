---
title: "logging resources"
parent: "Infrastructure / Logging"
grand_parent: "tpi-1"
---

## Overview

The `logging` infrastructure layer for the `tpi-1` cluster includes a standalone resource responsible for managing authentication and routing for VictoriaMetrics. This resource, a `VMAuth` instance, acts as a read proxy, enabling controlled access to specific endpoints of VictoriaMetrics services. It ensures unauthorized requests are routed appropriately and provides load balancing across multiple backend services.

## Resource Glossary

### VMAuth: `read-proxy`

- **Kind**: `VMAuth`
- **Name**: `read-proxy`
- **Namespace**: `logging`
- **Purpose**:  
  The `read-proxy` VMAuth resource is configured to act as an authentication and routing proxy for VictoriaMetrics services. It ensures that requests to specific endpoints are handled securely and routed to the appropriate backend services.
  
- **Details**:  
  - **Port**: The proxy listens on port `9428` for incoming requests.
  - **Unauthorized User Access**:  
    - Requests from unauthorized users are routed based on a URL map.  
    - The `src_paths` configuration specifies the paths that the proxy will handle, including `/select/.*` and the root path (`""`).
    - The `load_balancing_policy` is set to `first_available`, meaning the proxy will route requests to the first available backend service in the list.
    - The `retry_status_codes` include `503`, indicating that the proxy will retry requests if it encounters this status code.
  - **Backend Services**:  
    The proxy routes requests to the following backend services:
    - `vlogs-short-term-tpi-1-0.vlogs-short-term-tpi-1.logging.svc.cluster.local.:9428`
    - `vlogs-short-term-tpi-1-1.vlogs-short-term-tpi-1.logging.svc.cluster.local.:9428`
    - `vlsingle-short-term-nas.logging.svc.cluster.local.:9428`
    - (Commented out) `vlsingle-long-term-nas.logging.svc.cluster.local.:9428`
