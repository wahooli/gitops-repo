---
title: "etcd"
parent: "Apps"
grand_parent: "tpi-1"
---

# etcd

## Overview

The `etcd` component provides a distributed key-value store that is used as a backend for service discovery and configuration management in the `tpi-1` Kubernetes cluster. It is deployed using a HelmRelease managed by Flux and includes a gateway for external access. The deployment ensures high availability and data persistence, with support for SSL/TLS encryption and integration with other cluster components.

## Dependencies

The `etcd` HelmRelease has a dependency on the `cert-manager--cert-manager` HelmRelease. This dependency ensures that the required certificates for secure communication are provisioned and managed by cert-manager.

## Helm Chart(s)

### etcd--etcd
- **Chart Name**: `etcd`
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Release Name**: `etcd`
- **Target Namespace**: `etcd`
- **Reconciliation Interval**: 5 minutes

## Resource Glossary

### Networking
- **Service: `etcd`**
  - Type: `ClusterIP`
  - Ports:
    - `2379` (etcd-client)
    - `2380` (etcd-server)
    - `8080` (etcd-metrics)
  - Annotations:
    - `service.cilium.io/global`: Enables global service discovery.
    - `service.cilium.io/global-sync-endpoint-slices`: Synchronizes endpoint slices globally.

- **Service: `etcd-gateway`**
  - Type: `ClusterIP`
  - Port: `2379` (gateway)
  - Used for external access to the etcd cluster.

### Workloads
- **StatefulSet: `etcd`**
  - Manages the core etcd cluster with three replicas for high availability.
  - Persistent storage is enabled with a `ReadWriteOnce` access mode and a storage request of `2Gi` per replica.

- **Deployment: `etcd-gateway`**
  - Provides a gateway for external access to the etcd cluster.
  - Includes an init container (`wait-for-etcd`) to ensure readiness of the etcd cluster before starting.
  - Configured with a single replica.

### Security
- **TLS Certificates**
  - Server and client certificates are managed via cert-manager.
  - Certificates are stored in secrets (`etcd-client` and `etcd-server`) and mounted into the containers for secure communication.

- **Cilium Network Policies**
  - Policies are defined to restrict ingress and egress traffic for both the main etcd cluster and the gateway.
  - Ensures secure communication between etcd instances, the gateway, and other components like DNS and specific applications.

### Image Management
- **ImageRepository**
  - Repository: `quay.io/coreos/etcd`
  - Update Interval: 24 hours

- **ImagePolicy**
  - Policy: Semantic versioning (`vx.x.x`)
  - Ensures the etcd image is kept up-to-date with the latest compatible version.

### Configuration
- **Resource Requests**
  - Persistent storage: `2Gi` per replica.
  - Environment variable `ETCD_QUOTA_BACKEND_BYTES` is set to `6442450944` (6GB).

- **SSL/TLS**
  - SSL is enabled for secure communication.
  - Certificates are issued by the `clustermesh-issuer` ClusterIssuer.

- **Pod Annotations**
  - Backup annotations for Velero: `backup.velero.io/backup-volumes: data`.
  - Secret reloader annotations for automatic reload of secrets.

- **DNS Configuration**
  - Options:
    - `ndots: 1`
    - `edns0`

- **Backup**
  - Labels for daily and weekly backups are applied to resources.

## Deployment

- **Target Namespace**: `etcd`
- **Release Name**: `etcd`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: Unlimited retries for remediation on installation failure.

This component is managed by Flux and uses a floating Helm chart version (`>=0.1.0-0`), ensuring it stays up-to-date with the latest compatible releases. The deployment is designed for high availability, secure communication, and integration with other critical cluster components.
