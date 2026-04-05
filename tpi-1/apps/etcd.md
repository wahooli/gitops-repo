---
title: "etcd"
parent: "Apps"
grand_parent: "tpi-1"
---

# etcd

## Overview
The `etcd` component provides a distributed key-value store that is used for storing critical data in a Kubernetes cluster. It is essential for maintaining the state of the cluster and is often used by other components for configuration and service discovery.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease: etcd--etcd**
  - **Chart:** etcd
  - **Version:** latest (floating: >=0.1.0-0)
  - **Target Namespace:** etcd
  - **Provides:** A distributed key-value store with a gateway for client access.

## Dependencies
The `etcd--etcd` HelmRelease has a dependency on:
- **cert-manager--cert-manager**
  - **Provides:** Certificate management for securing communication between etcd instances and clients.

## Helm Chart(s)
- **Chart Name:** etcd
- **Repository:** wahooli (oci://ghcr.io/wahooli/charts)
- **Version:** latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service (etcd):** Exposes the etcd instances internally within the cluster, allowing communication over ports 2379 (client), 2380 (server), and 8080 (metrics).
- **Service (etcd-gateway):** Provides a gateway for clients to access the etcd cluster, listening on port 2379.

### Workload
- **StatefulSet (etcd):** Manages the deployment of etcd instances, ensuring that they are started in a specific order and maintain stable network identities.
- **Deployment (etcd-gateway):** Manages the etcd gateway, which facilitates client access to the etcd cluster.

### Configuration
- **ConfigMap (etcd-values-9k6gf7b6fk):** Contains configuration values for the etcd deployment, including global settings, image tags, replica counts, SSL settings, and network policies.

## Configuration Highlights
- **Image Tag:** `v3.6.10`
- **Replica Count:** 3 for etcd instances, 1 for the gateway.
- **Persistence:** Enabled with a storage request of 2Gi.
- **SSL:** Enabled with certificates managed by cert-manager.
- **Environment Variables:** Includes settings for etcd client certificates and connection parameters.

## Deployment
- **Target Namespace:** etcd
- **Release Name:** etcd
- **Reconciliation Interval:** 5 minutes
- **Install/Upgrade Behavior:** Remediation retries are set to unlimited (-1).
