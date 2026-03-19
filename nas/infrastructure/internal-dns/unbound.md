---
title: "unbound"
parent: "Infrastructure / Internal-dns"
grand_parent: "nas"
---

# Unbound

## Overview

The `unbound` component is a DNS resolver deployed in the `nas` cluster. It is responsible for providing DNS resolution services within the cluster, including caching and forwarding capabilities. The deployment leverages the Unbound DNS server and integrates with a Redis backend for caching purposes. This component is managed using Flux and Helm, ensuring automated and consistent deployments.

## Helm Chart(s)

### HelmRelease: `internal-dns--unbound`
- **Chart Name**: `unbound`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `unbound`
- **Target Namespace**: `internal-dns`
- **Reconciliation Interval**: `5m`

## Resource Glossary

### Networking
- **Service (3)**:
  - `unbound`: Exposes the Unbound DNS server on port 53 using a `ClusterIP` service.
  - `unbound-redis`: Provides access to the Redis instance used for caching, exposed on port 6379 as a `ClusterIP` service.
  - `unbound-redis-master`: Exposes the Redis master node on port 6379 as a `ClusterIP` service.

### Storage
- **ConfigMap (2)**:
  - `unbound-unboundconf`: Contains the main configuration for the Unbound DNS server, including server settings, caching, and Redis integration.
  - `unbound-redis-entrypoint-override`: Provides custom scripts for managing the Redis instance, including health checks and configuration for standalone or sentinel modes.

### Workloads
- **StatefulSet (1)**:
  - Manages the Redis instance for caching DNS records, ensuring data persistence and high availability.
- **Deployment (1)**:
  - Deploys the Unbound DNS server, configured to use Redis as a backend for caching.

### Security
- **ServiceAccount (1)**:
  - `unbound`: Service account used by the Unbound deployment for managing permissions within the cluster.

## Configuration Highlights

### Resource Requests and Limits
- **Unbound**:
  - Memory Requests: `450Mi`
  - Memory Limits: `640Mi`

### Persistence
- The Unbound DNS server uses a Redis backend for caching, which is deployed as a StatefulSet to ensure data persistence.

### Key Helm Values
- **Unbound Configuration**:
  - `unbound.config.existingConfigMap`: `unbound-config-c57m5f4k8f` (references a ConfigMap for Unbound configuration)
  - `unbound.zones.existingConfigMap`: `unbound-zones-9657chf299` (references a ConfigMap for DNS zones)
  - `unbound.port`: `${dns_svc_port:=53}` (configurable DNS service port)
  - `unbound.service.main.type`: `ClusterIP` (service type for the Unbound DNS server)
  - `unbound.service.main.clusterIP`: `${unbound_cluster_ip}` (configurable ClusterIP for the Unbound service)

- **Redis Configuration**:
  - `redis.enabled`: `true` (enables Redis as a caching backend)
  - `redisSidecar.enabled`: `false` (disables Redis sidecar)
  - `image.repository`: `madnuttah/unbound`
  - `image.tag`: `1.24.2-1` (managed by Flux ImagePolicy)

### Environment Variables
- `${dns_svc_port}`: Configurable DNS service port (default: `53`).
- `${unbound_cluster_ip}`: Configurable ClusterIP for the Unbound service.

## Deployment

- **Target Namespace**: `internal-dns`
- **Release Name**: `unbound`
- **Reconciliation Interval**: `5m`
- **Install/Upgrade Behavior**: Unlimited retries for remediation in case of failure.

This deployment is managed by Flux, with the HelmRelease resource ensuring the desired state is maintained. The configuration is sourced from multiple ConfigMaps (`unbound-values-2bc6t5dd2g`, `unbound-config-c57m5f4k8f`, `unbound-zones-9657chf299`), allowing for flexible and centralized management of settings.
