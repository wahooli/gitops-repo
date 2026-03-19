---
title: "authentik"
parent: "Apps"
grand_parent: "livingroom-pi"
---

# Authentik

## Overview

The `authentik` component is deployed in the `livingroom-pi` Kubernetes cluster and provides authentication and identity management services. It includes a Redis instance as a sub-component for caching and session management. The deployment leverages GitOps principles using Flux and Helm for automated and declarative management.

## Sub-components

### authentik--authentik-redis
- **Chart**: `redis`
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Target Namespace**: `authentik`
- **Purpose**: Provides a Redis instance with Sentinel for high availability, used by the `authentik` application for caching and session storage.

## Dependencies

The `authentik--authentik-redis` HelmRelease depends on the `cert-manager--cert-manager` HelmRelease. The `cert-manager` component is required to manage SSL/TLS certificates for secure communication between Redis nodes and clients.

## Helm Chart(s)

### authentik--authentik-redis
- **Chart Name**: `redis`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)

## Resource Glossary

### Namespace
- **Name**: `authentik`
- **Purpose**: Provides an isolated namespace for the `authentik` component and its sub-components.

### HelmRelease
- **Name**: `authentik--authentik-redis`
- **Purpose**: Manages the deployment of the Redis Helm chart in the `authentik` namespace.

### ImageRepository
- **Name**: `redis`
- **Purpose**: Tracks the Redis container image (`docker.io/redis`) for updates.

### ImagePolicy
- **Name**: `redis-8`
- **Purpose**: Ensures that only Redis images matching the semantic version range `8.0.x` are used.

### ConfigMap
- **Name**: `authentik-redis-values-7d67t6b554`
- **Purpose**: Provides custom Helm values for the Redis HelmRelease, including settings for persistence, networking, and Sentinel configuration.

### Rendered Kubernetes Resources (via Helm Template)
- **Service**: Three services are created to expose Redis and Sentinel endpoints.
- **StatefulSet**: Manages the Redis pods, ensuring stateful behavior and persistence.
- **ConfigMap**: Contains scripts and configurations for Redis and Sentinel operations.

## Configuration Highlights

- **Replica Count**: Redis is configured with a single replica (`replicaCount: 1`) and Sentinel for high availability.
- **Persistence**: Persistent storage is enabled for Redis data, with a volume size of `1Gi` and `ReadWriteOnce` access mode.
- **TLS/SSL**: Secure communication is enabled for Redis and Sentinel using certificates managed by `cert-manager`. The certificates are issued by a `ClusterIssuer` named `clustermesh-issuer`.
- **Cilium Network Policies**: Custom network policies are defined to control ingress and egress traffic for Redis and Sentinel, ensuring secure communication within the cluster.
- **Health Checks**: Custom health check scripts are included in a ConfigMap to monitor Redis and Sentinel health.
- **Pod Annotations**: Includes annotations for secret reloading (`secret.reloader.stakater.com/reload`).

## Deployment

- **Target Namespace**: `authentik`
- **Release Name**: `authentik-redis`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: Unlimited retries are configured for remediation in case of installation or upgrade failures.

This deployment ensures a robust and secure Redis setup with high availability and automated certificate management, tailored for the `authentik` application.
