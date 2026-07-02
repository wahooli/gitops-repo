---
title: "etcd"
parent: "Apps"
grand_parent: "livingroom-pi"
---

# etcd

## Overview
The `etcd` component provides a distributed key-value store that is used for storing critical data in a Kubernetes cluster. It is essential for maintaining the state of the cluster and is often used for service discovery and configuration management. This deployment consists of a single HelmRelease that manages the etcd instances and their associated resources.

## Sub-components
This component includes the following HelmRelease:
- **HelmRelease**: `etcd--etcd`
  - **Chart**: `etcd`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `etcd`
  - **Provides**: A distributed key-value store with a gateway for client access.

## Dependencies
The `etcd--etcd` HelmRelease has a dependency on:
- **cert-manager--cert-manager**: This component is responsible for managing SSL/TLS certificates, which are crucial for securing communication between etcd instances and clients.

## Helm Chart(s)
- **Chart Name**: `etcd`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service**: 
  - `etcd`: A ClusterIP service that exposes the etcd instances for internal communication. It listens on ports 2379 (client), 2380 (server), and 8080 (metrics).
  - `etcd-gateway`: A ClusterIP service that provides a gateway for clients to access etcd, listening on port 2379.

### Workload
- **Deployment**: 
  - `etcd-gateway`: Manages the gateway pods that allow external access to the etcd cluster. It includes an init container that waits for the etcd instances to be ready before starting the gateway.
  
- **StatefulSet**: 
  - Manages the etcd instances, ensuring they maintain their state across restarts and providing stable network identities.

### Configuration
- **ConfigMap**: 
  - `etcd-values-dgtg67k64k`: Contains configuration values for the etcd deployment, including global settings, image tags, replica counts, and SSL configurations.

## Configuration Highlights
- **Image**: `quay.io/coreos/etcd:v3.6.12`
- **Replica Count**: 3 for etcd instances, 1 for the gateway.
- **Persistence**: Enabled with 2Gi of storage requested.
- **SSL**: Enabled with a ClusterIssuer reference for certificate management.
- **Environment Variables**: Includes settings for client certificates and connection parameters.

## Deployment
- **Target Namespace**: `etcd`
- **Release Name**: `etcd`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The deployment will retry indefinitely on failure.
