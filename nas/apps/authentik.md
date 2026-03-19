---
title: "authentik"
parent: "Apps"
grand_parent: "nas"
---

# Authentik

## Overview

The `authentik` component provides an identity provider and authentication platform for the `nas` Kubernetes cluster. It is deployed using Flux and consists of multiple HelmReleases, each responsible for a specific sub-component of the deployment. These sub-components include the main Authentik application, a PostgreSQL database (Patroni), and a Redis instance for caching and session management.

## Sub-components

### 1. Authentik Remote Cluster
- **Chart**: `authentik-remote-cluster`
- **Version**: `2.0.0`
- **Repository**: [goauthentik](https://charts.goauthentik.io/) (HTTP)
- **Release Name**: `authentik-remote-cluster-default`
- **Target Namespace**: `default`
- **Reconciliation Interval**: 5 minutes

#### Rendered Kubernetes Resources
- `ServiceAccount` (1)
- `Secret` (1)
- `RoleBinding` (1)
- `Role` (1)
- `ClusterRoleBinding` (1)
- `ClusterRole` (1)

This sub-component deploys the main Authentik application, which provides the core identity and authentication services.

---

### 2. Patroni (PostgreSQL Database)
- **Chart**: `patroni`
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Repository**: wahooli ([oci://ghcr.io/wahooli/charts](oci://ghcr.io/wahooli/charts)) (OCI)
- **Release Name**: `authentik-patroni`
- **Target Namespace**: `authentik`
- **Reconciliation Interval**: 5 minutes
- **Dependencies**: `cert-manager--cert-manager`, `reflector--reflector`, `etcd--etcd`

#### Rendered Kubernetes Resources
- `ConfigMap` (5)
- `Service` (2)
- `StatefulSet` (1)
- `Secret` (1)
- `Deployment` (1)

This sub-component deploys a highly available PostgreSQL database using Patroni. It includes configurations for replication, failover, and integration with etcd for distributed consensus. It also supports connection pooling via PgBouncer.

---

### 3. Redis
- **Chart**: `redis`
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Repository**: wahooli ([oci://ghcr.io/wahooli/charts](oci://ghcr.io/wahooli/charts)) (OCI)
- **Release Name**: `authentik-redis`
- **Target Namespace**: `authentik`
- **Reconciliation Interval**: 5 minutes
- **Dependencies**: `cert-manager--cert-manager`

#### Rendered Kubernetes Resources
- `Service` (4)
- `ConfigMap` (3)
- `StatefulSet` (1)
- `Deployment` (1)

This sub-component deploys a Redis instance for caching and session management. It includes support for Redis Sentinel for high availability and uses HAProxy for proxying Redis connections.

---

## Namespace

The `authentik` component operates within the following namespaces:
- **`authentik`**: Primary namespace for the Authentik application and its dependencies.
- **`flux-system`**: Namespace for Flux-related resources, including HelmReleases and HelmRepositories.

---

## Dependencies

The `authentik` component has the following dependencies:
- `cert-manager--cert-manager`: Provides certificate management for the cluster.
- `reflector--reflector`: Ensures secrets and configmaps are synchronized across namespaces.
- `etcd--etcd`: Provides distributed consensus for the Patroni PostgreSQL cluster.

---

## Configuration

### Authentik Remote Cluster
- **Cluster Role**: Enabled
- **Service Account Secret**: Disabled
- **Service Ports**:
  - HTTP: Port `80` -> Target Port `9000`
  - HTTPS: Port `443` -> Target Port `9443`

### Patroni (PostgreSQL)
- **Database**: `authentik`
- **User**: `authentik`
- **Replication**: Enabled with 2 replicas
- **PgBouncer**: Enabled for connection pooling
- **SSL**: Enabled with certificates managed by `clustermesh-issuer`
- **Persistent Storage**: 4Gi for PostgreSQL data

### Redis
- **Sentinel**: Enabled for high availability
- **HAProxy**: Enabled for proxying Redis connections
- **SSL**: Enabled with certificates managed by `clustermesh-issuer`
- **Persistent Storage**: 1Gi for Redis data

---

## Image Management

### Patroni
- **Image Repository**: `ghcr.io/wahooli/docker/patroni-17`
- **Version Policy**: `x.x.x` (semantic versioning)
- **Current Tag**: `4.0.6`

### Redis
- **Image Repository**: `docker.io/redis`
- **Version Policy**: `8.0.x`

---

## Networking

### Authentik Server
- **Service Type**: `ClusterIP`
- **Ports**:
  - HTTP: `80`
  - HTTPS: `443`
- **Internal Traffic Policy**: `Cluster`

### Patroni
- **Ports**:
  - PostgreSQL: `5432`
  - PgBouncer: `6432`
  - Metrics: `8008`, `9630`, `9631`
- **Cilium Network Policies**: Configured for secure communication between Patroni instances, etcd, and other cluster components.

### Redis
- **Ports**:
  - Redis: `6379`
  - Sentinel: `26379`
- **Cilium Network Policies**: Configured for secure communication between Redis instances and proxies.

---

## Monitoring and Metrics
- **Patroni**: Metrics collection is disabled by default.
- **Redis**: Metrics collection is enabled via HAProxy.

---

## Additional Notes
- The `authentik` component is configured with various annotations for integration with Velero for backup and restore operations.
- The deployment uses Cilium network policies to enforce secure communication between sub-components and other cluster resources.
- The `authentik` component is designed for high availability and fault tolerance, with features like database replication and Redis Sentinel.
