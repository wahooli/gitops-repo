---
title: "authentik"
parent: "Apps"
grand_parent: "tpi-1"
---

# authentik

## Overview
The `authentik` component is deployed in the `tpi-1` cluster and is responsible for providing authentication services. It is managed using Flux and consists of multiple Helm releases, including the main `authentik` service and its dependencies.

## Namespace
The component is deployed in the `authentik` namespace.

## Helm Repository
The Helm charts for `authentik` are sourced from the following repository:
- **Name**: goauthentik
- **URL**: [https://charts.goauthentik.io/](https://charts.goauthentik.io/)
- **Update Interval**: 24 hours

## Helm Releases
### 1. authentik
- **Release Name**: authentik
- **Chart Version**: 2025.12.4
- **Interval**: 5 minutes
- **Target Namespace**: authentik
- **Dependencies**:
  - authentik--authentik-redis
  - authentik--authentik-patroni
- **Values**:
  - Configurations for logging, database connections, and Redis settings.
  - TLS settings for Redis and PostgreSQL.
  - Email configuration for notifications.

### 2. authentik-remote-cluster
- **Release Name**: authentik-remote-cluster-default
- **Chart Version**: 2.0.0
- **Interval**: 5 minutes
- **Target Namespace**: default
- **Dependencies**:
  - authentik--authentik
- **Values**:
  - Cluster role settings and service account configurations.

### 3. authentik--authentik-patroni
- **Release Name**: authentik-patroni
- **Chart Version**: >=0.1.0-0
- **Interval**: 5 minutes
- **Target Namespace**: authentik
- **Dependencies**:
  - cert-manager
  - reflector
  - etcd
- **Values**:
  - PostgreSQL settings, including user credentials and backup configurations.
  - HAProxy settings for load balancing.

## Deployments
### authentik-apply-blueprints
- **Deployment Name**: authentik-apply-blueprints
- **Replicas**: 1
- **Container**: Uses a pause container for initialization.
- **Init Container**: Applies blueprints using a script.

## Networking
### HTTPRoute
- **Name**: authentik
- **Hostnames**:
  - auth.wahoo.li
  - authentik.wahoo.li
- **Backend Reference**: authentik-server on port 80
- **Timeouts**: 60 seconds for backend requests.

## Image Repositories
- **authentik-server**: `ghcr.io/goauthentik/server`
- **patroni-17**: `ghcr.io/wahooli/docker/patroni-17`

## Image Policies
- **authentik**: Policy for managing image versions.
- **patroni-17**: Policy for managing image versions.

## Configuration Management
Configuration values for `authentik` are sourced from ConfigMaps, which include base values and environment-specific overrides.

## Security
- **Service Accounts**: Managed for both the main authentik service and the patroni database.
- **TLS**: Configured for secure communication between services.

## Notes
- Ensure that environment variables for database passwords and other sensitive information are set appropriately in your Kubernetes secrets.
- Regularly check the Helm repository for updates to the charts used in this deployment.
