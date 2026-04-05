---
title: "etcd"
parent: "Apps"
grand_parent: "livingroom-pi"
---

# etcd

## Overview
The `etcd` component provides a distributed key-value store that is used for storing critical data in a Kubernetes cluster. It is essential for maintaining the state of the cluster and is often used by various Kubernetes components for configuration and service discovery.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease: etcd--etcd**
  - **Chart**: etcd
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: etcd
  - **Provides**: A distributed key-value store with features such as high availability, data persistence, and secure communication.

## Dependencies
The `etcd--etcd` HelmRelease has a dependency on:
- **cert-manager--cert-manager**: This component is responsible for managing SSL/TLS certificates, which are crucial for securing communication between etcd instances.

## Helm Chart(s)
- **Chart Name**: etcd
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service**: 
  - `etcd`: Exposes the etcd instances for client communication on port 2379 (client), 2380 (server), and 8080 (metrics). It uses a ClusterIP type, allowing internal communication within the cluster.
  - `etcd-gateway`: Provides a gateway for accessing etcd, allowing clients to connect to the etcd cluster through a single endpoint.

### Storage
- **StatefulSet**: Manages the deployment of etcd instances, ensuring that they are started in a specific order and maintain their identities across restarts. It is configured to have a replica count of 3 for high availability.
  
### Security
- **ConfigMap**: Contains configuration values for etcd, including global settings, SSL configurations, and backup policies. This is crucial for defining how etcd operates and interacts with other components.

## Configuration Highlights
- **Image**: Uses `quay.io/coreos/etcd:v3.6.10`.
- **Replica Count**: Configured to have 3 replicas for high availability.
- **Persistence**: Enabled with a storage request of 2Gi.
- **SSL**: SSL is enabled with a reference to a ClusterIssuer for certificate management.
- **Environment Variables**: Includes settings for etcd client certificates and connection parameters.

## Deployment
- **Target Namespace**: etcd
- **Release Name**: etcd
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The installation is set to retry indefinitely on failure.
