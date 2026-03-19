---
title: "internal-dns resources"
parent: "Infrastructure / Internal-dns"
grand_parent: "tpi-1"
---

## Overview

The `internal-dns` infrastructure layer for the `tpi-1` cluster contains resources that support internal DNS functionality. These resources include a dedicated namespace for organizational purposes and a service to expose DNS-related functionalities such as DNS resolution and secure DNS communication within the cluster. Together, they enable internal DNS services to operate efficiently and securely.

## Resource Glossary

### Namespace: `internal-dns`
- **Kind**: `Namespace`
- **Name**: `internal-dns`
- **Purpose**: This namespace is created to logically group and isolate resources related to internal DNS services within the cluster.
- **Details**: The namespace is labeled with `internal-services: "true"`, which can be used for organizational or operational purposes, such as applying policies or selecting resources.

---

### Service: `bind9-nas`
- **Kind**: `Service`
- **Name**: `bind9-nas`
- **Namespace**: `internal-dns`
- **Purpose**: This service exposes DNS and related functionalities to other components within the cluster.
- **Details**:
  - **Type**: `ClusterIP` — The service is accessible only within the cluster.
  - **Ports**:
    - `dns-udp` (UDP, port 53): Handles DNS queries over UDP.
    - `dns-tcp` (TCP, port 53): Handles DNS queries over TCP.
    - `https` (TCP, port 443): Reserved for HTTPS traffic.
    - `dns-tls` (TCP, port 853): Supports DNS over TLS for encrypted DNS communication.
  - **Internal Traffic Policy**: `Cluster` — Ensures that traffic is routed only within the cluster.
  - **Annotations**: Includes `service.cilium.io/global: "true"`, which may indicate that the service is globally accessible within the Cilium network.

These resources collectively enable and manage internal DNS services for the `tpi-1` cluster.
