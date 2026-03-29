---
title: "authentik"
parent: "Apps"
grand_parent: "tpi-1"
---

# authentik

The `authentik` component is deployed in the `tpi-1` cluster and consists of multiple sub-components, including the main authentik application, Redis, and Patroni for PostgreSQL management.

## Overview

- **Namespace**: `authentik`
- **Helm Repository**: [goauthentik](https://charts.goauthentik.io/)
- **Main Chart Version**: `2025.12.4`
- **Patroni Chart Version**: `>=0.1.0-0`
- **Remote Cluster Chart Version**: `2.0.0`

## Components

### 1. Authentik

- **HelmRelease Name**: `authentik--authentik`
- **Release Name**: `authentik`
- **Interval**: 5 minutes
- **Values**:
  - Log level set to `warn`
  - PostgreSQL and Redis configurations with TLS enabled
  - Email settings configured for sending emails

### 2. Patroni

- **HelmRelease Name**: `authentik--authentik-patroni`
- **Release Name**: `authentik-patroni`
- **Interval**: 5 minutes
- **Values**:
  - PostgreSQL user and database configurations
  - Backup scripts and annotations for Velero integration
  - Cilium network policies for secure communication

### 3. Redis

- **HelmRelease Name**: `authentik--authentik-redis`
- **Release Name**: `authentik-redis`
- **Interval**: 5 minutes
- **Values**:
  - Redis configurations are set to be disabled in this deployment.

### 4. Remote Cluster

- **HelmRelease Name**: `default--authentik-remote-cluster`
- **Release Name**: `authentik-remote-cluster-default`
- **Interval**: 5 minutes
- **Post Renderers**: Kustomize patches to modify RoleBinding for the authentik namespace.

## Networking

- **HTTPRoute**: Configured to route traffic to the authentik service based on specified hostnames.
- **Ingress**: Not enabled for the main authentik service; however, HTTP routing is managed through the Envoy gateway.

## Image Repositories

- **Authentik Server**: `ghcr.io/goauthentik/server`
- **Patroni**: `ghcr.io/wahooli/docker/patroni-17`

## Configuration Management

- **ConfigMaps**: Used to manage values for both authentik and patroni deployments.
- **Secrets**: Environment variables for sensitive data such as database passwords are sourced from Kubernetes secrets.

## Notes

- The deployment includes various annotations for monitoring and backup purposes.
- Ensure that the necessary secrets and ConfigMaps are created and updated as required for the application to function correctly.

This documentation provides a high-level overview of the `authentik` deployment in the `tpi-1` cluster, detailing its components, configurations, and networking setup.
