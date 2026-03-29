---
title: "authentik"
parent: "Apps"
grand_parent: "tpi-1"
---

# authentik

## Overview
The `authentik` component is deployed in the `tpi-1` cluster and provides identity management and authentication services. It is configured using Helm charts and Flux for GitOps.

## Namespace
The component is deployed in the `authentik` namespace.

## Helm Releases
### authentik
- **Chart**: `authentik`
- **Version**: `2025.12.4`
- **Source**: [goauthentik](https://charts.goauthentik.io/)
- **Interval**: 5 minutes
- **Values**: Configured using multiple ConfigMaps, including `authentik-values-gdhg2f68bm`.

### authentik-remote-cluster
- **Chart**: `authentik-remote-cluster`
- **Version**: `2.0.0`
- **Source**: [goauthentik](https://charts.goauthentik.io/)
- **Interval**: 5 minutes
- **Post Renderers**: Includes a Kustomize patch for RoleBinding.

### authentik-patroni
- **Chart**: `patroni`
- **Version**: `>=0.1.0-0`
- **Source**: wahooli
- **Interval**: 5 minutes
- **Values**: Configured using ConfigMaps, including `authentik-patroni-values-fctf8ct669`.

## Image Repositories
- **authentik-server**: `ghcr.io/goauthentik/server`
- **patroni-17**: `ghcr.io/wahooli/docker/patroni-17`

## Deployments
### authentik-apply-blueprints
- **Replicas**: 1
- **Container**: Uses `registry.k8s.io/pause:3.10` for a pause container.
- **Init Container**: Runs a script to apply blueprints using the `authentik` API.

## HTTP Routes
The `authentik` service is exposed via an `HTTPRoute` with the following hostnames:
- `auth.wahoo.li`
- `auth.absolutist.it`
- `authentik.wahoo.li`
- `authentik.absolutist.it`

## Configuration
### Values Configuration
The configuration for `authentik` includes:
- Logging settings
- Database connection details for PostgreSQL and Redis
- Email settings for notifications
- Security context and volume mounts for TLS certificates

### Patroni Configuration
The `patroni` configuration includes:
- PostgreSQL settings
- High availability settings
- Backup scripts and policies

## Dependencies
The `authentik` HelmRelease depends on:
- `authentik--authentik-redis`
- `authentik--authentik-patroni`

## Notes
- The deployment uses Flux for continuous delivery and GitOps practices.
- Ensure that the necessary secrets and ConfigMaps are created and available in the `authentik` namespace for the deployment to function correctly.
