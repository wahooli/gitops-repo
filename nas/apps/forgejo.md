---
title: "forgejo"
parent: "Apps"
grand_parent: "nas"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a collaborative platform for version control and project management. This deployment includes additional components such as Redis for caching and Patroni for PostgreSQL clustering.

## Deployment Details
The Forgejo component is deployed in the `forgejo` namespace within the `nas` cluster using Flux CD for GitOps. The deployment consists of multiple Helm releases:

### 1. Forgejo
- **Helm Chart Version**: 16.2.1
- **Release Name**: `forgejo`
- **Namespace**: `forgejo`
- **Source**: OCI repository at `oci://code.forgejo.org/forgejo-helm`
- **Values**: Configurations are sourced from multiple ConfigMaps, including base, shared, and optional values.

### 2. Redis
- **Helm Chart Version**: `>=0.1.0-0`
- **Release Name**: `forgejo-redis`
- **Namespace**: `forgejo`
- **Source**: Helm repository `wahooli`
- **Values**: Configurations include settings for Redis Sentinel and persistence.

### 3. Patroni
- **Helm Chart Version**: `>=0.1.0-0`
- **Release Name**: `forgejo-patroni`
- **Namespace**: `forgejo`
- **Source**: Helm repository `wahooli`
- **Values**: Configurations include PostgreSQL settings and cluster management.

## Services
- **SSH Load Balancer**: Exposes SSH access to Forgejo.
  - **Type**: LoadBalancer
  - **Ports**: 
    - 22 (SSH)
    - 2222 (SSH Proxy)

## Ingress
- **HTTP Routes**:
  - `forgejo-public`: Routes traffic to the Forgejo HTTP service on port 8923.
  - `forgejo-private`: Routes traffic to the Forgejo HTTP service on port 3000 for internal access.

## Image Repositories
- **Forgejo**: `code.forgejo.org/forgejo/forgejo`
- **Syncthing**: `syncthing/syncthing:2.0.15`
- **Anubis**: `ghcr.io/techarohq/anubis:v1.25.0`

## Configuration
### Base Values
- **Service Type**: ClusterIP for HTTP and SSH services.
- **Persistence**: Enabled with a size of 10Gi.
- **Init Containers**: Used for copying SSH keys and JWT secrets.

### Shared Values
- **Replica Count**: 1
- **Metrics**: Disabled by default.
- **OAuth Configuration**: Integrated with Authentik for OpenID Connect.

### Additional Configurations
- **Database**: PostgreSQL with Patroni for high availability.
- **Caching**: Redis used for session management and caching.
- **Storage**: MinIO configured for object storage.

## Security Policies
- **HTTPRoute Security**: Policies are defined to restrict access based on client CIDR ranges.

## Notes
- The deployment is configured to allow for high availability and scalability.
- Ensure that all secrets and sensitive configurations are managed securely within Kubernetes.
