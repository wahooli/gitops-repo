---
title: "forgejo"
parent: "Apps"
grand_parent: "tpi-1"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a user-friendly interface for managing repositories. This deployment includes additional components such as Redis and Patroni for database management, and Syncthing for file synchronization.

## Deployment Details
The Forgejo deployment is managed using Flux and consists of the following Helm releases:

### 1. Forgejo
- **Chart Version**: 16.2.1
- **Release Name**: `forgejo`
- **Namespace**: `forgejo`
- **Source Repository**: `oci://code.forgejo.org/forgejo-helm`
- **Update Interval**: 5 minutes
- **Dependencies**:
  - Redis (`forgejo--forgejo-redis`)
  - Patroni (`forgejo--forgejo-patroni`)
  - SeaweedFS (`seaweedfs--seaweedfs`)

### 2. Redis
- **Chart Version**: `>=0.1.0-0`
- **Release Name**: `forgejo-redis`
- **Namespace**: `forgejo`
- **Update Interval**: 5 minutes

### 3. Patroni
- **Chart Version**: `>=0.1.0-0`
- **Release Name**: `forgejo-patroni`
- **Namespace**: `forgejo`
- **Update Interval**: 5 minutes

## Configuration
The configuration for Forgejo is primarily managed through ConfigMaps, which include base values, shared values, and specific overrides. Key configurations include:

- **Service Configuration**:
  - HTTP service on port 3000
  - SSH service on port 22
  - LoadBalancer for SSH with annotations for external DNS

- **Database Configuration**:
  - PostgreSQL managed by Patroni
  - Connection details to Redis for caching and session management

- **Storage Configuration**:
  - MinIO used for object storage, integrated with SeaweedFS

- **Security**:
  - OAuth2 integration with Authentik
  - JWT secrets and other sensitive configurations sourced from Kubernetes secrets

## Probes
Health checks are configured for the Forgejo application:
- **Liveness Probe**: Checks TCP socket on the HTTP port.
- **Readiness Probe**: HTTP GET request to `/api/healthz`.

## Ingress and Networking
Forgejo exposes its services through HTTPRoutes configured for both public and private access:
- **Public Route**: Accessible via `git.${domain_wahoo_li}`
- **Private Route**: Restricted access for internal services.

## Additional Components
- **Syncthing**: Deployed as an additional container for file synchronization, configured to communicate with other Forgejo components.
- **Anubis**: A bot service integrated for handling specific tasks within the Forgejo environment.

## Notes
- Ensure that all secrets referenced in the configuration are created and available in the `forgejo` namespace.
- Regular backups are configured for Redis and PostgreSQL to ensure data integrity.

This documentation serves as a guide for managing and understanding the Forgejo deployment within the `tpi-1` cluster.
