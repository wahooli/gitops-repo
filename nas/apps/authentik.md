---
title: "authentik"
parent: "Apps"
grand_parent: "nas"
---

# authentik

## Overview
The `authentik` component is deployed in the `nas` cluster and is responsible for providing authentication services. It utilizes various Kubernetes resources to manage its deployment, including Helm releases, ConfigMaps, Secrets, and RBAC configurations.

## Namespace
The component is deployed in the `authentik` namespace.

## Helm Repository
- **Name**: `goauthentik`
- **URL**: [https://charts.goauthentik.io/](https://charts.goauthentik.io/)
- **Update Interval**: 24 hours

## Helm Releases
### authentik--authentik
- **Chart**: `authentik`
- **Version**: `2025.12.4`
- **Namespace**: `authentik`
- **Interval**: 5 minutes
- **Release Name**: `authentik`
- **Values Source**:
  - ConfigMap: `authentik-values-8gk4dh676k`
    - `values-base.yaml`
    - `values-shared.yaml`
    - `values.yaml` (optional)
  - ConfigMap: `authentik-helmrelease-overrides` (optional)

### Dependencies
- `authentik--authentik-redis`
- `authentik--authentik-patroni`

## Configurations
### ConfigMap: authentik-values-8gk4dh676k
Contains configuration values for the authentik deployment, including:
- Logging settings
- PostgreSQL and Redis configurations
- Email settings
- Security context and volume mounts

### ConfigMap: authentik-blueprint-apply-script-677dtm4b8t
A script used to apply blueprints to the authentik service, ensuring that the necessary configurations are set up correctly.

## Services
### Service Account
- **Name**: `authentik`
- **Namespace**: `default`
- **Type**: `kubernetes.io/service-account-token`

### RBAC
- **ClusterRole**: `authentik-outpost`
- **ClusterRoleBinding**: `authentik-outpost`
- **Role**: `authentik-outpost` (in both `default` and `authentik` namespaces)
- **RoleBinding**: `authentik-outpost` (in both `default` and `authentik` namespaces)

## Deployment
### Deployment: authentik-apply-blueprints
- **Replicas**: 1
- **Init Containers**: 
  - `apply-blueprints`: Executes the blueprint application script.
- **Main Container**: 
  - `pause`: A placeholder container.

## HTTP Routes
### HTTPRoute: authentik
- **Hostnames**:
  - `auth.wahoo.li`
  - `auth.absolutist.it`
  - `authentik.wahoo.li`
  - `authentik.absolutist.it`
- **Backend Reference**: `authentik-server` on port 80

## Image Repository
- **Name**: `authentik-server`
- **Image**: `ghcr.io/goauthentik/server`
- **Update Interval**: 24 hours

## Image Policy
- **Name**: `authentik`
- **Policy**: Semantic versioning policy for image updates.

## Notes
Ensure that the necessary secrets and environment variables are configured correctly for the deployment to function as expected. The deployment relies on external services such as PostgreSQL and Redis, which must be available and properly configured.
