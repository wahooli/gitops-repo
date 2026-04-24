---
title: "authentik"
parent: "Apps"
grand_parent: "nas"
---

# authentik

## Overview
The `authentik` component is deployed in the `nas` cluster and provides identity and access management capabilities. It is configured using Helm and Flux for GitOps-based deployment.

## Namespace
The component is deployed in the `authentik` namespace.

## Helm Repository
The Helm chart for `authentik` is sourced from the following repository:
- **Name**: goauthentik
- **URL**: [https://charts.goauthentik.io/](https://charts.goauthentik.io/)
- **Update Interval**: 24 hours

## Helm Releases
### authentik
- **Release Name**: authentik
- **Chart Version**: 2025.12.4
- **Target Namespace**: authentik
- **Update Interval**: 5 minutes
- **Dependencies**:
  - authentik--authentik-redis
  - authentik--authentik-patroni
- **Values**: Configurations are sourced from multiple ConfigMaps:
  - `authentik-values-8gk4dh676k` (base and shared values)
  - `authentik-helmrelease-overrides` (optional)

## Image Repository
- **Image**: `ghcr.io/goauthentik/server`
- **Update Interval**: 24 hours

## Configuration
The configuration for `authentik` includes:
- Logging settings
- Database connection details for PostgreSQL and Redis
- Email server configurations
- Security context and volume mounts for TLS certificates

## HTTP Routes
The `authentik` service is exposed via HTTP routes that handle various paths and set appropriate response headers. The routes are configured to work with the Envoy gateway.

## RBAC Configuration
The deployment includes several RBAC resources:
- **ClusterRole**: `authentik-outpost` with permissions to manage custom resource definitions and other resources.
- **RoleBindings**: Bind the `authentik` service account to the necessary roles in both the `default` and `authentik` namespaces.

## Blueprint Management
The deployment includes a script for managing blueprints in `authentik`, which handles the creation, updating, and disabling of blueprints based on YAML configurations.

## Additional Notes
- The component is designed to be resilient with automatic remediation on failure.
- It supports TLS for secure connections to Redis and PostgreSQL.
- Metrics are enabled for monitoring the `authentik` server.

This documentation provides a comprehensive overview of the `authentik` deployment in the `nas` cluster, detailing its configuration, dependencies, and operational aspects.
