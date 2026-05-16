---
title: "forgejo"
parent: "Apps"
grand_parent: "tpi-1"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a collaborative platform for software development. This deployment is configured to run in the `forgejo` namespace of the `tpi-1` cluster using Flux for GitOps.

## Helm Releases
The deployment consists of the following Helm releases:

### forgejo
- **Chart Version**: 16.2.1
- **Source**: OCI repository at `oci://code.forgejo.org/forgejo-helm`
- **Namespace**: `flux-system`
- **Release Name**: `forgejo`
- **Target Namespace**: `forgejo`
- **Install Interval**: 5 minutes
- **Dependencies**:
  - `forgejo--forgejo-redis`
  - `forgejo--forgejo-patroni`
  - `seaweedfs--seaweedfs`
- **Configuration**:
  - Base values are overridden by shared and per-cluster configurations.
  - The service is configured with HTTP and SSH endpoints, along with persistence for data storage.
  - Additional configurations include OAuth settings, database connection details, and security settings.

### forgejo--forgejo-redis
- **Chart**: Redis
- **Version**: `>=0.1.0-0`
- **Namespace**: `flux-system`
- **Release Name**: `forgejo-redis`
- **Install Interval**: 5 minutes
- **Configuration**:
  - Redis is set up with sentinel support and persistence enabled.

### forgejo--forgejo-patroni
- **Chart**: Patroni
- **Version**: `>=0.1.0-0`
- **Namespace**: `flux-system`
- **Release Name**: `forgejo-patroni`
- **Install Interval**: 5 minutes
- **Configuration**:
  - Patroni is used for PostgreSQL high availability.

## Services
- **SSH Load Balancer**: Exposes SSH access on port 22 and a proxy on port 2222.
- **HTTP Routes**: Configured for both public and private access to the Forgejo application.

## Image Repositories
- **Forgejo**: `code.forgejo.org/forgejo/forgejo` (tag: `15.0.1-rootless`)
- **Syncthing**: `syncthing/syncthing` (tag: `2.0.16`)
- **Anubis**: `ghcr.io/techarohq/anubis` (tag: `v1.25.0`)

## Configuration Details
- **Service Configuration**:
  - HTTP service is set to `ClusterIP` with specific annotations for Cilium.
  - SSH service is configured for local traffic policy.
- **Database Configuration**:
  - PostgreSQL is used with connection details specified for Patroni.
- **Storage Configuration**:
  - MinIO is used for object storage with specific bucket paths for various data types.

## Security Policies
- Security policies are defined to restrict access based on client CIDR ranges for private routes.

## Additional Notes
- The deployment includes various init containers and volume mounts for shared keys and TLS certificates.
- Health checks are configured for liveness and readiness probes to ensure the application is running smoothly.

This documentation provides a comprehensive overview of the Forgejo deployment in the `tpi-1` cluster, detailing its components, configurations, and operational settings.
