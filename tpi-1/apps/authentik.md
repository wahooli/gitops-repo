---
title: "authentik"
parent: "Apps"
grand_parent: "tpi-1"
---

# authentik

## Overview
`authentik` is an open-source identity provider designed to manage user authentication and authorization. It is deployed in the `authentik` namespace of the Kubernetes cluster `tpi-1`.

## Deployment Details

### Namespace
- **Name**: `authentik`

### Helm Repository
- **Name**: `goauthentik`
- **URL**: [https://charts.goauthentik.io/](https://charts.goauthentik.io/)
- **Update Interval**: 24 hours

### Helm Releases
#### authentik--authentik
- **Chart Version**: `2025.12.4`
- **Release Name**: `authentik`
- **Target Namespace**: `authentik`
- **Update Interval**: 5 minutes
- **Install Timeout**: 10 minutes
- **Remediation**: Automatically retries on failure

### Dependencies
- `authentik--authentik-redis`
- `authentik--authentik-patroni`

### Configuration
The deployment uses several ConfigMaps for configuration values:
- **Base Values**: `values-base.yaml`
- **Shared Values**: `values-shared.yaml`
- **Optional Values**: `values.yaml` (from `authentik-helmrelease-overrides`)

### Image Repository
- **Name**: `authentik-server`
- **Image**: `ghcr.io/goauthentik/server`
- **Update Interval**: 24 hours

### HTTP Routes
- **Hostnames**:
  - `auth.wahoo.li`
  - `auth.absolutist.it`
  - `authentik.wahoo.li`
  - `authentik.absolutist.it`
- **Backend Reference**: `authentik-server` on port 80

## RBAC Configuration
- **Service Account**: `authentik` in the `default` namespace
- **Cluster Role**: `authentik-outpost`
- **Role Bindings**: 
  - `authentik-outpost` in both `default` and `authentik` namespaces

## Scripts and Blueprints
- A ConfigMap contains a script for applying blueprints to the authentik instance, ensuring that the application is ready before executing further tasks.
- Blueprints for initializing groups and policies are defined in separate YAML files within a ConfigMap.

## Notes
- The deployment is configured to use TLS for Redis and PostgreSQL connections.
- Email settings are configured for sending notifications.
- The deployment includes metrics collection for monitoring purposes.

This documentation provides a comprehensive overview of the `authentik` deployment in the Kubernetes cluster, detailing its configuration, dependencies, and operational aspects.
