---
title: "forgejo"
parent: "Apps"
grand_parent: "tpi-1"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a collaborative platform for managing Git repositories. This documentation outlines the deployment of Forgejo in the Kubernetes cluster `tpi-1` using Flux for GitOps.

## Deployment Details
The Forgejo deployment consists of multiple Helm releases that work together to provide the necessary services.

### Helm Releases
1. **Forgejo**
   - **Release Name**: `forgejo`
   - **Chart Version**: `16.2.1`
   - **Source**: OCI repository at `oci://code.forgejo.org/forgejo-helm`
   - **Namespace**: `forgejo`
   - **Interval**: 5 minutes
   - **Dependencies**:
     - Redis (managed by `forgejo--forgejo-redis`)
     - Patroni (managed by `forgejo--forgejo-patroni`)
     - SeaweedFS (managed by `seaweedfs--seaweedfs`)

2. **Redis**
   - **Release Name**: `forgejo-redis`
   - **Chart Version**: `>=0.1.0-0`
   - **Source**: Helm repository `wahooli`
   - **Namespace**: `forgejo`
   - **Interval**: 5 minutes

3. **Patroni**
   - **Release Name**: `forgejo-patroni`
   - **Chart Version**: `>=0.1.0-0`
   - **Source**: Helm repository `wahooli`
   - **Namespace**: `forgejo`
   - **Interval**: 5 minutes

## Configuration
The configuration for Forgejo is managed through several ConfigMaps that define base values, shared values, and specific overrides.

### Key Configurations
- **Service Configuration**:
  - HTTP service runs on port `3000`.
  - SSH service runs on port `22` with an additional proxy on port `2222`.

- **Database Configuration**:
  - PostgreSQL is used as the database backend, configured to connect through Patroni.

- **Persistence**:
  - Data persistence is enabled with a volume size of `10Gi`.

- **OAuth Configuration**:
  - Forgejo is configured to use an OpenID Connect provider for authentication.

### Environment Variables
Forgejo utilizes several environment variables for configuration, including secrets for database access and JWT tokens.

## Services
Forgejo exposes several services:
- **SSH Load Balancer**: Exposes SSH access to the Forgejo instance.
- **HTTP Routes**: Configured for both public and private access through Envoy gateways.

### Ingress and Routes
- **Public HTTP Route**: Accessible via `git.${domain_wahoo_li:=wahoo.li}` on port `8923`.
- **Private HTTP Route**: Accessible via the same hostname on port `3000`.

## Image Repositories
Forgejo utilizes multiple image repositories to manage its container images:
- **Forgejo Image**: `code.forgejo.org/forgejo/forgejo:14.0.3-rootless`
- **Syncthing Image**: `syncthing/syncthing:2.0.15`
- **Anubis Image**: `ghcr.io/techarohq/anubis:v1.25.0`

## Monitoring and Probes
Forgejo includes health checks:
- **Liveness Probe**: Checks TCP connectivity on the HTTP port.
- **Readiness Probe**: Checks the health endpoint `/api/healthz`.

## Conclusion
This documentation provides a comprehensive overview of the Forgejo deployment in the `tpi-1` Kubernetes cluster. The deployment is managed using Flux, ensuring that the configuration is version-controlled and easily reproducible.
