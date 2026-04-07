---
title: "forgejo"
parent: "Apps"
grand_parent: "tpi-1"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a collaborative platform for software development. This deployment integrates with Redis for caching and Patroni for PostgreSQL clustering.

## Deployment Details
The `forgejo` component is deployed in the `flux-system` namespace with the following specifications:

- **Helm Chart Version**: 16.2.1
- **Release Name**: forgejo
- **Target Namespace**: forgejo
- **Update Interval**: 5 minutes

### Dependencies
The `forgejo` deployment depends on the following components:
- **Redis**: Managed by the `forgejo--forgejo-redis` HelmRelease.
- **Patroni**: Managed by the `forgejo--forgejo-patroni` HelmRelease.
- **SeaweedFS**: Managed by the `seaweedfs--seaweedfs` HelmRelease.

## Configuration
The deployment configuration is sourced from multiple ConfigMaps, allowing for flexible customization:
- **Base Values**: `values-base.yaml`
- **Shared Values**: `values-shared.yaml`
- **Optional Values**: `values.yaml` (overrides)

### Key Configuration Options
- **Service Type**: ClusterIP for HTTP and SSH services.
- **Persistence**: Enabled with a size of 10Gi.
- **Replica Count**: 1
- **OAuth Configuration**: Integrated with Authentik for OpenID Connect.
- **Database Configuration**: PostgreSQL with SSL enabled.

### Image Repositories
- **Forgejo Image**: `code.forgejo.org/forgejo/forgejo:14.0.3-rootless`
- **Syncthing Image**: `syncthing/syncthing:2.0.15`
- **Anubis Image**: `ghcr.io/techarohq/anubis:v1.25.0`

## Services
### SSH Load Balancer
- **Service Name**: `forgejo-ssh-lb`
- **Type**: LoadBalancer
- **Ports**: 
  - SSH: 22
  - SSH Proxy Protocol: 2222

### HTTP Routes
- **Public Route**: Exposes Forgejo on `git.${domain_wahoo_li}` via port 8923.
- **Private Route**: Exposes Forgejo on `git.${domain_wahoo_li}` via port 3000.

## Security Policies
A security policy is defined to restrict access to the private HTTP route, allowing only specific CIDR ranges.

## Additional Components
### Redis
- **Helm Chart Version**: `>=0.1.0-0`
- **Release Name**: `forgejo-redis`
- **Configuration**: Sentinel enabled with a replica count of 3.

### Patroni
- **Helm Chart Version**: `>=0.1.0-0`
- **Release Name**: `forgejo-patroni`
- **Configuration**: PostgreSQL bootstrap with a database named `forgejo`.

## Monitoring and Probes
- **Liveness Probe**: Enabled, checks TCP socket on HTTP port.
- **Readiness Probe**: Enabled, checks HTTP GET on `/api/healthz`.

## Conclusion
The Forgejo deployment in the `tpi-1` cluster is a robust setup for managing Git repositories, leveraging Redis for caching and Patroni for database management, ensuring high availability and performance.
