---
title: "authentik"
parent: "Apps"
grand_parent: "tpi-1"
---

# authentik

The `authentik` component is deployed in the `tpi-1` cluster and consists of multiple sub-components, including the main authentik service, a Redis instance, and a Patroni-managed PostgreSQL database. Below is the detailed documentation for the deployment.

## Namespace
- **Namespace**: `authentik`

## Helm Repository
- **Name**: `goauthentik`
- **URL**: [https://charts.goauthentik.io/](https://charts.goauthentik.io/)
- **Update Interval**: 24 hours

## Helm Releases
### authentik
- **Release Name**: `authentik`
- **Chart Version**: `2025.12.4`
- **Interval**: 5 minutes
- **Target Namespace**: `authentik`
- **Values**: Loaded from ConfigMaps `authentik-values-gdhg2f68bm` (base and custom values)

### authentik-remote-cluster
- **Release Name**: `authentik-remote-cluster-default`
- **Chart Version**: `2.0.0`
- **Interval**: 5 minutes
- **Target Namespace**: `default`
- **Values**: Custom values defined inline

### authentik-patroni
- **Release Name**: `authentik-patroni`
- **Chart Version**: `>=0.1.0-0`
- **Interval**: 5 minutes
- **Target Namespace**: `authentik`
- **Values**: Loaded from ConfigMaps `authentik-patroni-values-fctf8ct669` (base and custom values)

## Deployments
### authentik-apply-blueprints
- **Replicas**: 1
- **Container**: 
  - **Image**: `registry.k8s.io/pause:3.10`
  - **Init Container**: `apply-blueprints` using `alpine:3.21` to apply blueprints.

## Image Repositories
- **authentik-server**: `ghcr.io/goauthentik/server`
- **patroni-17**: `ghcr.io/wahooli/docker/patroni-17`

## HTTP Routes
- **Route Name**: `authentik`
- **Hostnames**: 
  - `auth.wahoo.li`
  - `auth.absolutist.it`
  - `authentik.wahoo.li`
  - `authentik.absolutist.it`
- **Backend Reference**: `authentik-server` on port 80

## Configurations
### Values Overview
- **Logging**: 
  - Log level set to `warn`
  - Error reporting disabled
- **PostgreSQL Configuration**: 
  - Database: `authentik`
  - User: `authentik`
  - Password: `${authentik_database_password}`
- **Redis Configuration**: 
  - Host: `authentik-redis-proxy.authentik.svc.cluster.local`
  - TLS enabled
- **Email Configuration**: 
  - SMTP settings for sending emails

### Patroni Configuration
- **PostgreSQL**: Managed by Patroni with replication and backup configurations.
- **Persistence**: Enabled for PostgreSQL data.

## Dependencies
- The `authentik` release depends on:
  - `authentik--authentik-redis`
  - `authentik--authentik-patroni`

## Notes
- Ensure that all referenced secrets and ConfigMaps are created and properly configured before deploying the `authentik` component.
- The deployment includes configurations for metrics, DNS settings, and network policies to ensure secure communication between components.
