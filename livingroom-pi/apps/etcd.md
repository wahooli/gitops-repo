---
title: "etcd"
parent: "Apps"
grand_parent: "livingroom-pi"
---

# etcd

## Overview
The `etcd` component is a distributed key-value store that provides a reliable way to store data across a cluster. It is crucial for maintaining the state of distributed systems and is often used in Kubernetes for storing configuration data and service discovery. This deployment includes a HelmRelease that manages the installation and configuration of etcd within the `etcd` namespace.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease: etcd--etcd**
  - **Chart:** etcd
  - **Version:** latest (floating: >=0.1.0-0)
  - **Target Namespace:** etcd
  - **Provides:** StatefulSet for etcd instances, a gateway for client access, and associated services.

## Dependencies
The `etcd--etcd` HelmRelease has a dependency on:
- **cert-manager--cert-manager**: This component is responsible for managing TLS certificates, which are essential for securing communication between etcd instances.

## Helm Chart(s)
- **Chart Name:** etcd
- **Repository:** wahooli (oci://ghcr.io/wahooli/charts)
- **Version:** latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service (etcd)**: Exposes the etcd instances and provides access to the etcd client and server ports (2379 for client, 2380 for server, and 8080 for metrics). It uses a ClusterIP type, allowing internal communication within the cluster.
- **Service (etcd-gateway)**: Provides a gateway for client access to etcd, allowing external clients to connect to the etcd cluster.

### Workload
- **StatefulSet**: Manages the deployment of etcd instances, ensuring that they are started in a specific order and maintain stable network identities. It is configured to run 3 replicas for high availability.
- **Deployment (etcd-gateway)**: Manages the etcd gateway, which allows clients to connect to the etcd cluster. It includes health checks to ensure the gateway is operational.

### Configuration
- **ConfigMap (etcd-values-gd4g5fdfmt)**: Contains configuration values for the etcd deployment, including global settings, image tags, SSL configuration, and resource requests.

## Configuration Highlights
- **Image Tag:** `v3.7.1` for the etcd container.
- **Replica Count:** 3 for the etcd instances to ensure high availability.
- **Persistence:** Enabled with a storage request of 2Gi for the etcd data.
- **SSL:** Enabled with a reference to a ClusterIssuer for certificate management.
- **Environment Variables:** Includes settings for etcd client certificates and connection parameters.

## Deployment
- **Target Namespace:** etcd
- **Release Name:** etcd
- **Reconciliation Interval:** 5 minutes
- **Install/Upgrade Behavior:** The installation is configured to retry indefinitely in case of failure.
