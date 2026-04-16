---
title: "forgejo"
parent: "Apps"
grand_parent: "tpi-1"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a platform for managing Git repositories. This deployment is configured to run in the `forgejo` namespace of the `tpi-1` cluster using Flux for GitOps.

## Components

### HelmRelease: forgejo
- **Chart**: `forgejo`
- **Version**: `16.2.1`
- **Namespace**: `flux-system`
- **Release Name**: `forgejo`
- **Interval**: 5 minutes
- **Dependencies**:
  - `forgejo--forgejo-redis`
  - `forgejo--forgejo-patroni`
  - `seaweedfs--seaweedfs`
- **Values**: Configurations are sourced from multiple ConfigMaps, including `forgejo-values-b65md82299`.

### HelmRelease: forgejo--forgejo-redis
- **Chart**: `redis`
- **Version**: `>=0.1.0-0`
- **Namespace**: `flux-system`
- **Release Name**: `forgejo-redis`
- **Interval**: 5 minutes
- **Values**: Configurations are sourced from `forgejo-redis-values-tdctdc68tt`.

### HelmRelease: forgejo--forgejo-patroni
- **Chart**: `patroni`
- **Version**: `>=0.1.0-0`
- **Namespace**: `flux-system`
- **Release Name**: `forgejo-patroni`
- **Interval**: 5 minutes
- **Values**: Configurations are sourced from `forgejo-patroni-values-d8924gct7f`.

## Services
- **SSH Load Balancer**: 
  - **Name**: `forgejo-ssh-lb`
  - **Type**: LoadBalancer
  - **Ports**: 
    - 22 (SSH)
    - 2222 (SSH Proxy Protocol)
  - **Annotations**: Includes external DNS and Cilium annotations.

## Ingress
- **HTTP Routes**:
  - **Public**: Routes traffic to the Forgejo HTTP service on port 8923.
  - **Private**: Routes traffic to the Forgejo HTTP service on port 3000, with a security policy allowing access only from specific CIDR ranges.

## Configuration
The deployment is configured using multiple ConfigMaps that define various settings, including:
- **Service Configuration**: HTTP and SSH service settings, including annotations for Cilium.
- **Database Configuration**: PostgreSQL settings for Forgejo, including connection details.
- **Storage Configuration**: Integration with SeaweedFS for object storage.
- **OAuth and Security Settings**: Configuration for OAuth providers and security features.

## Image Repositories
- **Forgejo**: `code.forgejo.org/forgejo/forgejo:14.0.3-rootless`
- **Syncthing**: `syncthing/syncthing:2.0.15`
- **Anubis**: `ghcr.io/techarohq/anubis:v1.25.0`

## Notes
- The deployment uses Flux for continuous delivery, with automated updates based on the specified intervals.
- Ensure that the necessary secrets and ConfigMaps are created and maintained for the deployment to function correctly.
