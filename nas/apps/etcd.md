---
title: "etcd"
parent: "Apps"
grand_parent: "nas"
---

# etcd

## Overview
The `etcd` component provides a distributed key-value store that is used for storing critical data in a Kubernetes cluster. It is essential for maintaining the state of the cluster and is often used for service discovery and configuration management. This deployment includes a HelmRelease that manages the installation and configuration of `etcd`.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease: etcd--etcd**
  - **Chart:** etcd
  - **Version:** latest (floating: >=0.1.0-0)
  - **Target Namespace:** etcd
  - **Provides:** A distributed key-value store with a gateway for client access.

## Dependencies
The `etcd--etcd` HelmRelease has a dependency on:
- **cert-manager--cert-manager**: This component is responsible for managing SSL/TLS certificates, which are crucial for securing communication between `etcd` instances.

## Helm Chart(s)
- **Chart Name:** etcd
- **Repository:** wahooli (oci://ghcr.io/wahooli/charts)
- **Version:** latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service (etcd)**: Exposes the `etcd` instances for internal communication. It has multiple ports:
  - `2379` for client access.
  - `2380` for server-to-server communication.
  - `8080` for metrics.
  
- **Service (etcd-gateway)**: Provides a gateway for client access to the `etcd` cluster, allowing external clients to communicate with the `etcd` instances.

### Storage
- **StatefulSet (etcd)**: Manages the deployment of `etcd` instances, ensuring that they maintain their identity and persistent storage across restarts.

### Security
- **ConfigMap (etcd-values-f9g2f6gfmk)**: Contains configuration values for the `etcd` deployment, including SSL settings and backup configurations.

## Configuration Highlights
- **Replica Count**: The `etcd` StatefulSet is configured to have 3 replicas for high availability.
- **Persistence**: Data persistence is enabled with a storage request of 2Gi.
- **SSL Configuration**: SSL is enabled for secure communication, with references to `ClusterIssuer` for certificate management.
- **Environment Variables**: Key environment variables for `etcd` include:
  - `ETCD_QUOTA_BACKEND_BYTES`: Set to "6442450944" to limit the size of the backend storage.
  - Certificates for secure communication are mounted from Kubernetes secrets.

## Deployment
- **Target Namespace:** etcd
- **Release Name:** etcd
- **Reconciliation Interval:** 5 minutes
- **Install/Upgrade Behavior:** The HelmRelease is configured to retry indefinitely on failure.
