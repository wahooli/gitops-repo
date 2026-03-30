---
title: "authentik"
parent: "Apps"
grand_parent: "tpi-1"
---

# authentik

## Overview
The `authentik` component is deployed in the `tpi-1` cluster and is responsible for providing authentication services. It utilizes Helm for deployment and is managed through Flux CD.

## Namespace
The component is deployed in the `authentik` namespace.

## Helm Releases
### authentik
- **Chart**: `authentik`
- **Version**: `2025.12.4`
- **Source**: [goauthentik](https://charts.goauthentik.io/)
- **Interval**: 5 minutes
- **Dependencies**:
  - `authentik--authentik-redis`
  - `authentik--authentik-patroni`
- **Values**: Configurations are sourced from multiple ConfigMaps, including `authentik-values-gdhg2f68bm` and `authentik-helmrelease-overrides`.

### authentik-remote-cluster
- **Chart**: `authentik-remote-cluster`
- **Version**: `2.0.0`
- **Source**: [goauthentik](https://charts.goauthentik.io/)
- **Interval**: 5 minutes
- **Dependencies**:
  - `authentik--authentik`
- **Values**: Custom configurations for the remote cluster deployment.

### authentik--authentik-patroni
- **Chart**: `patroni`
- **Version**: `>=0.1.0-0`
- **Source**: [wahooli](https://charts.wahooli.io/)
- **Interval**: 5 minutes
- **Dependencies**: 
  - `cert-manager--cert-manager`
  - `reflector--reflector`
  - `etcd--etcd`
- **Values**: Configurations are sourced from ConfigMaps, including `authentik-patroni-values-fctf8ct669` and `authentik-patroni-helmrelease-overrides`.

## Image Repositories
- **authentik-server**: `ghcr.io/goauthentik/server`
- **patroni-17**: `ghcr.io/wahooli/docker/patroni-17`

## HTTP Routes
The `authentik` service is exposed through HTTP routes with the following hostnames:
- `auth.wahoo.li`
- `auth.absolutist.it`
- `authentik.wahoo.li`
- `authentik.absolutist.it`

## Deployments
### authentik-apply-blueprints
- **Replicas**: 1
- **Init Container**: Runs a script to apply blueprints using the `authentik` API.

## Configuration
The configuration for `authentik` includes:
- Logging settings
- Database connection details for PostgreSQL and Redis
- Email server configurations
- TLS settings for secure connections

## Notes
- The deployment is managed using Flux CD, ensuring that the desired state is maintained.
- The `authentik` component is designed to be resilient, with automatic remediation for failures and configurable timeouts for installations.
