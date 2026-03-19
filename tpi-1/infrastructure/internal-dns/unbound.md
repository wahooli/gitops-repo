---
title: "unbound"
parent: "Infrastructure / Internal-dns"
grand_parent: "tpi-1"
---

# Unbound

## Overview

The `unbound` component provides a DNS resolver service for the Kubernetes cluster `tpi-1`. It is deployed using a Helm chart and managed by Flux. The service is configured to handle DNS queries and caching, with additional support for Redis-based caching. The deployment includes multiple Kubernetes resources such as ConfigMaps, Services, a Deployment, and a StatefulSet. 

## Helm Chart(s)

### internal-dns--unbound
- **Chart Name**: `unbound`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `unbound`
- **Target Namespace**: `internal-dns`
- **Reconciliation Interval**: `5m`

## Resource Glossary

### Networking
- **Service (unbound)**: Exposes the Unbound DNS resolver as a `ClusterIP` service on port `53` (default DNS port). The exact cluster IP is configurable via the `${unbound_cluster_ip}` parameter.
- **Service (unbound-redis)**: A `ClusterIP` service for the Redis instance used by Unbound for caching. It listens on port `6379` for Redis connections.
- **Service (unbound-redis-master)**: A `ClusterIP` service specifically for the Redis master instance, also listening on port `6379`.

### Configuration
- **ConfigMap (unbound-unboundconf)**: Contains the main configuration file for Unbound, including server settings, module configurations, and Redis integration details.
- **ConfigMap (unbound-redis-entrypoint-override)**: Provides custom scripts for managing the Redis instance, including health checks and sentinel configuration.
- **ConfigMap (unbound-values-2bc6t5dd2g)**: Stores additional Helm values, including `values-base.yaml`, `values.yaml`, and optionally `values-extra.yaml`. These files define configurations such as resource limits, Redis settings, and Unbound-specific options.
- **ConfigMap (unbound-config-c57m5f4k8f)**: Contains additional Unbound configuration files, such as `access-control.conf`, `interfaces.conf`, `logging.conf`, `performance.conf`, `remote-control.conf`, `security.conf`, and `trust-anchor.conf`.
- **ConfigMap (unbound-zones-9657chf299)**: Defines DNS zones and local zone configurations for Unbound.

### Workload
- **Deployment (unbound)**: Deploys the Unbound DNS resolver. It uses the `madnuttah/unbound:1.24.2-1` container image, with resource requests of `450Mi` memory and limits of `640Mi` memory.
- **StatefulSet (unbound-redis)**: Deploys a Redis instance for caching DNS records. Redis is configured to run in standalone mode with a single master node.

### Security
- **ServiceAccount (unbound)**: A dedicated service account for the Unbound deployment, with `automountServiceAccountToken` set to `true`.

### Image Management
- **ImageRepository (unbound)**: Tracks the `madnuttah/unbound` image with an update interval of `24h`.
- **ImagePolicy (unbound)**: Ensures the image tag follows a numerical ascending order policy, with tags extracted in the format `major.minor.patch.build`.

## Configuration Highlights

- **Resource Requests and Limits**:
  - Unbound container: `450Mi` memory request, `640Mi` memory limit.
- **Redis Integration**:
  - Redis caching is enabled, with a single master node deployed as a StatefulSet.
  - Redis configuration is provided via a ConfigMap, including health check and sentinel scripts.
- **DNS Service**:
  - Default DNS port: `${dns_svc_port:=53}`.
  - Configurable cluster IP: `${unbound_cluster_ip}`.
- **Unbound Configuration**:
  - Custom configuration is provided via multiple ConfigMaps, including access control, logging, performance tuning, and security settings.
  - Redis is used as a backend for DNS caching.

## Deployment

- **Target Namespace**: `internal-dns`
- **Release Name**: `unbound`
- **Reconciliation Interval**: `5m`
- **Install Behavior**: Unlimited retries on installation failure (`retries: -1`).

This deployment is managed by Flux and uses a floating version of the `unbound` Helm chart (`>=0.1.0-0`) from the `wahooli` OCI repository. Configuration values are sourced from multiple ConfigMaps, allowing for flexible customization.
