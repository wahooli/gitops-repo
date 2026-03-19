---
title: "etcd"
parent: "Apps"
grand_parent: "livingroom-pi"
---

# etcd

## Overview

The `etcd` component provides a distributed key-value store that is used as a backend for service discovery and configuration management in the `livingroom-pi` Kubernetes cluster. It is deployed using a HelmRelease managed by Flux and includes a gateway for external access. This deployment ensures high availability and fault tolerance by running multiple replicas of the etcd service.

## Dependencies

The `etcd` HelmRelease depends on the `cert-manager--cert-manager` HelmRelease. The `cert-manager` is used to manage SSL/TLS certificates for secure communication between etcd instances and clients.

## Helm Chart(s)

### etcd--etcd
- **Chart Name:** `etcd`
- **Repository:** `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version:** `latest` (floating: `>=0.1.0-0`)
- **Release Name:** `etcd`
- **Target Namespace:** `etcd`
- **Reconciliation Interval:** 5 minutes

## Resource Glossary

### Namespace
- **Name:** `etcd`
- **Purpose:** Provides an isolated namespace for the etcd resources within the cluster.

### ImageRepository
- **Name:** `etcd`
- **Purpose:** Tracks the `quay.io/coreos/etcd` container image for the etcd deployment.

### ImagePolicy
- **Name:** `etcd`
- **Purpose:** Ensures that the etcd deployment uses the latest image version matching the semantic versioning range `vx.x.x`.

### HelmRelease
- **Name:** `etcd--etcd`
- **Purpose:** Manages the deployment of the etcd Helm chart, including its configuration and lifecycle.

### ConfigMap
- **Name:** `etcd-values-b8c67gkkdd`
- **Purpose:** Provides custom configuration values for the etcd Helm chart, including settings for replicas, persistence, SSL, and networking.

### Services
1. **etcd Service**
   - **Type:** ClusterIP
   - **Ports:**
     - `2379` (etcd-client)
     - `2380` (etcd-server)
     - `8080` (etcd-metrics)
   - **Purpose:** Exposes the etcd cluster for internal communication and metrics collection.
   - **Annotations:** Configured for global service discovery with Cilium.

2. **etcd-gateway Service**
   - **Type:** ClusterIP
   - **Port:** `2379` (gateway)
   - **Purpose:** Provides a gateway for external access to the etcd cluster.

### StatefulSet
- **Name:** `etcd`
- **Purpose:** Manages the main etcd cluster with persistent storage and high availability.

### Deployment
- **Name:** `etcd-gateway`
- **Purpose:** Deploys the etcd gateway for external access to the etcd cluster.

## Configuration Highlights

- **Image Version:** `quay.io/coreos/etcd:v3.6.8`
- **Replica Count:** 3 for the main etcd cluster, 1 for the gateway.
- **Persistence:** Enabled with `2Gi` of storage per replica, using `ReadWriteOnce` access mode.
- **SSL Configuration:**
  - SSL is enabled for secure communication.
  - Certificates are managed by `cert-manager` using a `ClusterIssuer` named `clustermesh-issuer`.
- **Environment Variables:**
  - `ETCD_QUOTA_BACKEND_BYTES`: Set to `6442450944` (6 GiB).
- **Networking:**
  - Cilium Network Policies are configured to allow secure communication between etcd instances and the gateway.
  - DNS options include `ndots:1` and `edns0`.
- **Extra Arguments:**
  - `--snapshot-count=100000`
  - `--auto-compaction-mode=periodic`
  - `--auto-compaction-retention=1h`
  - `--logger=zap`
  - `--log-outputs=stderr`

## Deployment

- **Target Namespace:** `etcd`
- **Release Name:** `etcd`
- **Reconciliation Interval:** 5 minutes
- **Install/Upgrade Behavior:** Unlimited retries for remediation in case of failures.

This deployment ensures a secure, highly available, and scalable etcd cluster with robust configuration options for persistence, networking, and SSL.
