---
title: "internal-dns resources"
parent: "Infrastructure / Internal-dns"
grand_parent: "nas"
---

## Overview

The `internal-dns` infrastructure layer provides DNS services within the `nas` cluster. It includes a dedicated namespace for internal DNS-related resources and a service configuration for Bind9 DNS functionality. These resources work together to ensure internal DNS resolution and secure communication within the cluster.

## Resource Glossary

### Namespace: `internal-dns`
- **Kind**: Namespace
- **Name**: `internal-dns`
- **Labels**: `internal-services: "true"`
- **Purpose**: This namespace is dedicated to hosting resources related to internal DNS services within the cluster. It provides logical isolation and organization for DNS-related components.

### Service: `bind9-tpi-1`
- **Kind**: Service
- **Name**: `bind9-tpi-1`
- **Namespace**: `internal-dns`
- **Annotations**: 
  - `service.cilium.io/global: "true"`: Indicates that the service is globally accessible across the cluster.
- **Purpose**: This service exposes the Bind9 DNS functionality within the cluster. It provides multiple ports for DNS resolution and secure communication:
  - **Port 53 (UDP)**: Handles DNS queries over UDP.
  - **Port 53 (TCP)**: Handles DNS queries over TCP.
  - **Port 443 (TCP)**: Reserved for HTTPS communication.
  - **Port 853 (TCP)**: Supports DNS over TLS for secure DNS resolution.
- **Internal Traffic Policy**: `Cluster` - Ensures that traffic is routed within the cluster.
- **Session Affinity**: `None` - No session affinity is configured.
- **Type**: `ClusterIP` - The service is accessible within the cluster using a virtual IP address.
