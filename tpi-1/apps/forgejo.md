---
title: "forgejo"
parent: "Apps"
grand_parent: "tpi-1"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a collaborative platform for developers. This documentation outlines the deployment of Forgejo in the Kubernetes cluster `tpi-1` using Flux and Helm.

## Deployment Details

### Helm Releases
The Forgejo deployment consists of the following Helm releases:

1. **Forgejo**
   - **Chart Version**: 16.2.1
   - **Namespace**: `forgejo`
   - **Release Name**: `forgejo`
   - **Dependencies**:
     - Redis (forgejo--forgejo-redis)
     - Patroni (forgejo--forgejo-patroni)
     - SeaweedFS (seaweedfs--seaweedfs)
   - **Install Interval**: 5 minutes
   - **Values**: Configurations are sourced from multiple ConfigMaps.

2. **Redis**
   - **Chart Version**: `>=0.1.0-0`
   - **Namespace**: `forgejo`
   - **Release Name**: `forgejo-redis`
   - **Install Interval**: 5 minutes

3. **Patroni**
   - **Chart Version**: `>=0.1.0-0`
   - **Namespace**: `forgejo`
   - **Release Name**: `forgejo-patroni`
   - **Install Interval**: 5 minutes

### Image Repositories
- **Forgejo Image**: `code.forgejo.org/forgejo/forgejo`
- **Syncthing Image**: `syncthing/syncthing:2.0.16`
- **Anubis Image**: `ghcr.io/techarohq/anubis:v1.25.0`

### Services
- **SSH Load Balancer**: 
  - **Type**: LoadBalancer
  - **Ports**: 
    - 22 (SSH)
    - 2222 (SSH Proxy)
  
### Ingress and HTTP Routes
- **Public HTTP Route**: Exposes Forgejo at `git.${domain_wahoo_li:=wahoo.li}`.
- **Private HTTP Route**: Also exposes Forgejo at the same hostname but for internal traffic.

### Configuration
The deployment uses multiple ConfigMaps for configuration management, including:
- `forgejo-values-ccttfcmb5c`: Base and shared values for Forgejo.
- `anubis-config`: Configuration for the Anubis bot.
- `syncthing-config`: Configuration for Syncthing.

### Persistent Storage
- **Persistence**: Enabled with a size of 10Gi for Forgejo data.

### Health Checks
- **Liveness Probe**: Checks the health of the application via TCP on the HTTP port.
- **Readiness Probe**: Checks the health of the application via HTTP on the `/api/healthz` endpoint.

## Notes
- Ensure that the necessary secrets and environment variables are configured for secure operation.
- The deployment is designed to be resilient and scalable, leveraging Redis for caching and session management, and Patroni for PostgreSQL high availability.

This documentation provides a high-level overview of the Forgejo deployment in the Kubernetes cluster `tpi-1`. For detailed configuration and operational procedures, refer to the respective ConfigMaps and Helm chart documentation.
