---
title: "forgejo"
parent: "Apps"
grand_parent: "nas"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a collaborative platform for managing Git repositories. It is deployed in the `forgejo` namespace of the `nas` cluster using Flux for GitOps.

## Components
The Forgejo deployment consists of the following sub-components:

### 1. Forgejo
- **Helm Chart**: `forgejo`
- **Version**: `16.2.1`
- **Namespace**: `flux-system`
- **Release Name**: `forgejo`
- **Target Namespace**: `forgejo`
- **Install Interval**: Every 5 minutes
- **Dependencies**:
  - Redis (forgejo--forgejo-redis)
  - Patroni (forgejo--forgejo-patroni)
  - SeaweedFS (seaweedfs--seaweedfs)

#### Configuration
- **Service Type**: ClusterIP for HTTP and SSH services.
- **Persistence**: Enabled with a size of 10Gi.
- **Init Containers**: Used for copying SSH host keys and JWT keys.
- **Environment Variables**: Configured for OAuth, database connection, and security settings.

### 2. Redis
- **Helm Chart**: `redis`
- **Version**: `>=0.1.0-0`
- **Release Name**: `forgejo-redis`
- **Namespace**: `flux-system`
- **Install Interval**: Every 5 minutes

#### Configuration
- **Sentinel**: Enabled for high availability.
- **Persistence**: Data persistence is enabled.

### 3. Patroni
- **Helm Chart**: `patroni`
- **Version**: `>=0.1.0-0`
- **Release Name**: `forgejo-patroni`
- **Namespace**: `flux-system`
- **Install Interval**: Every 5 minutes

## Services
- **SSH Load Balancer**: Exposes SSH service on port 22 and a proxy on port 2222.
- **HTTP Routes**: Configured for both public and private access to the Forgejo application.

## Ingress
- **Public Ingress**: Routes traffic to the Forgejo HTTP service on port 8923.
- **Private Ingress**: Routes traffic to the Forgejo HTTP service on port 3000.

## Image Repositories
- **Forgejo Image**: `code.forgejo.org/forgejo/forgejo`
- **Syncthing Image**: `syncthing/syncthing:2.0.16`
- **Anubis Image**: `ghcr.io/techarohq/anubis:v1.25.0`

## Image Policies
- Policies are defined for managing image updates based on semantic versioning.

## Configurations
- Configurations are managed through ConfigMaps, allowing for flexible adjustments to the deployment without modifying the Helm charts directly.

## Notes
- Ensure that the necessary secrets and ConfigMaps are created and available in the `forgejo` namespace for the deployment to function correctly.
- The deployment is designed for high availability and scalability, leveraging Redis and Patroni for database management.
