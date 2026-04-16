---
title: "authentik"
parent: "Apps"
grand_parent: "livingroom-pi"
---

# authentik

## Overview
The `authentik` component is a deployment that provides authentication services within the Kubernetes cluster `livingroom-pi`. It utilizes Redis as a backend for session management and caching, ensuring high availability and performance. This deployment includes a Redis instance configured with Sentinel for monitoring and failover capabilities.

## Sub-components
- **HelmRelease: authentik--authentik-redis**
  - **Chart:** redis
  - **Version:** latest (floating: >=0.1.0-0)
  - **Target Namespace:** authentik
  - **Provides:** A highly available Redis instance with Sentinel support, configured for use with the authentik service.

## Dependencies
- **cert-manager--cert-manager**: This dependency is required for managing TLS certificates, ensuring secure communication for the Redis instance.

## Helm Chart(s)
- **Chart Name:** redis
- **Repository:** wahooli (oci://ghcr.io/wahooli/charts) [OCI]
- **Version:** latest (floating: >=0.1.0-0)

## Resource Glossary
- **Namespace:** 
  - `authentik`: A dedicated namespace for the authentik component, isolating its resources from other services.
  
- **ImageRepository:** 
  - `redis`: Defines the source for the Redis Docker image, ensuring the deployment uses the correct version.

- **ImagePolicy:** 
  - `redis-8`: Specifies the policy for pulling Redis images, allowing only versions in the 8.0.x range.

- **HelmRelease:** 
  - `authentik--authentik-redis`: Manages the deployment of the Redis chart, including configuration and lifecycle management.

- **ConfigMap:** 
  - `authentik-redis-values-df58ff722h`: Contains configuration values for the Redis deployment, including settings for persistence, replication, and network policies.

- **Service:** 
  - Three services are created to expose the Redis instance and Sentinel, allowing other components to communicate with Redis.

- **StatefulSet:** 
  - Manages the Redis pods, ensuring they maintain their state and identity across restarts, which is crucial for a database service.

## Configuration Highlights
- **Persistence:** 
  - Redis data is persisted with a storage request of 1Gi, ensuring data durability.
  
- **Replica Count:** 
  - The Redis deployment is configured with a replica count of 3 for high availability.

- **TLS Configuration:** 
  - TLS is enabled for secure communication, with certificates managed by cert-manager.

- **Cilium Network Policies:** 
  - Network policies are defined to control traffic to and from the Redis pods, enhancing security.

## Deployment
- **Target Namespace:** authentik
- **Release Name:** authentik-redis
- **Reconciliation Interval:** 5m
- **Install/Upgrade Behavior:** The HelmRelease is set to retry indefinitely on failure, ensuring resilience during deployment.
