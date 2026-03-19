---
title: "etcd"
parent: "Apps"
grand_parent: "nas"
---

# etcd

## Overview
The `etcd` component provides a distributed key-value store used for storing and managing critical cluster data, such as configuration, state, and service discovery. It is deployed in the `nas` cluster and serves as a highly available and reliable backend for various Kubernetes components and applications.

This deployment includes a primary `etcd` StatefulSet for the core etcd cluster and an `etcd-gateway` Deployment for facilitating access to the etcd cluster.

## Dependencies
The `etcd` HelmRelease depends on the `cert-manager--cert-manager` HelmRelease. This dependency ensures that certificates required for secure communication within the etcd cluster are properly issued and managed.

## Helm Chart(s)
### etcd
- **Chart Name**: `etcd`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `etcd`
- **Target Namespace**: `etcd`

## Resource Glossary
### Networking
- **Service: `etcd`**
  - Provides access to the etcd cluster for client and peer communication.
  - Ports:
    - `2379`: etcd client communication.
    - `2380`: etcd peer communication.
    - `8080`: etcd metrics.
  - Type: `ClusterIP` with `publishNotReadyAddresses` enabled for stateful service discovery.

- **Service: `etcd-gateway`**
  - Provides access to the etcd gateway for external communication.
  - Port:
    - `2379`: Gateway communication.
  - Type: `ClusterIP` with `publishNotReadyAddresses` enabled.

### Workloads
- **StatefulSet: `etcd`**
  - Manages the core etcd cluster with three replicas for high availability.
  - Configured with persistent storage for data durability.
  - Uses the `quay.io/coreos/etcd:v3.6.8` image.

- **Deployment: `etcd-gateway`**
  - Provides a gateway for accessing the etcd cluster.
  - Single replica deployment using the `quay.io/coreos/etcd:v3.6.8` image.
  - Includes readiness and liveness probes to ensure availability.

### Storage
- **Persistent Volumes**
  - The `etcd` StatefulSet uses persistent volumes for storing data.
  - Storage requests: `2Gi` per replica.
  - Access mode: `ReadWriteOnce`.

### Security
- **TLS Certificates**
  - Secure communication between etcd components is enabled via TLS.
  - Certificates are managed by `cert-manager` using a `ClusterIssuer` named `clustermesh-issuer`.
  - Client and server certificates are stored in Kubernetes secrets (`etcd-client` and `etcd-server`).

### Image Management
- **ImageRepository: `etcd`**
  - Tracks the `quay.io/coreos/etcd` image.
  - Updates checked every 24 hours.

- **ImagePolicy: `etcd`**
  - Ensures the image tag adheres to the semantic versioning range `vx.x.x`.

### Configuration
- **ConfigMap: `etcd-values-f68589f589`**
  - Contains Helm values for configuring the etcd cluster and gateway.
  - Key configurations:
    - `replicaCount`: 3 for the etcd cluster.
    - `ssl.enabled`: `true` for secure communication.
    - `ETCD_QUOTA_BACKEND_BYTES`: `6442450944` (6GB) for backend storage quota.
    - `ciliumNetworkPolicies`: Defines network policies for secure communication between etcd components and other services.
    - `persistence.data.enabled`: `true` with `2Gi` storage requests.

## Configuration Highlights
- **Replica Count**: 3 for the etcd StatefulSet, 1 for the etcd-gateway Deployment.
- **Persistence**: Enabled with 2Gi storage per etcd replica.
- **TLS**: Enabled with certificates managed by `cert-manager`.
- **Environment Variables**:
  - `ETCD_QUOTA_BACKEND_BYTES`: Configures the backend storage quota.
  - `ETCDCTL_CACERT`, `ETCDCTL_CERT`, `ETCDCTL_KEY`: Paths to TLS certificates for secure communication.
- **Network Policies**: Configured using CiliumNetworkPolicies to restrict access to the etcd cluster and gateway.

## Deployment
- **Target Namespace**: `etcd`
- **Release Name**: `etcd`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: Unlimited retries for remediation in case of installation or upgrade failures.
