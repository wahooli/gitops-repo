---
title: "authentik"
parent: "Apps"
grand_parent: "tpi-1"
---

# Authentik

Authentik is deployed in the `tpi-1` cluster to provide identity and access management services. This documentation outlines the configuration and deployment details for the Authentik component and its sub-components.

## Namespace

Authentik is deployed in the `authentik` namespace. The namespace is labeled for internal services and managed by Flux.

## HelmRepository

The Authentik Helm charts are sourced from the official repository:

- **Name:** `goauthentik`
- **URL:** [https://charts.goauthentik.io/](https://charts.goauthentik.io/)
- **Update Interval:** 24 hours

## HelmReleases

### Authentik Core

- **Name:** `authentik--authentik`
- **Chart:** `authentik`
- **Version:** `2025.12.4`
- **Release Name:** `authentik`
- **Namespace:** `authentik`
- **Update Interval:** 5 minutes
- **Dependencies:**
  - `authentik--authentik-redis`
  - `authentik--authentik-patroni`
- **Values Configuration:**
  - Configured via `authentik-values-c8k44fhg7f` ConfigMap.
  - Includes base values (`values-base.yaml`) and additional overrides (`values.yaml`).
  - Key configurations:
    - **Log Level:** `warn`
    - **PostgreSQL:** Uses Patroni for database management with TLS enabled.
    - **Redis:** Configured with TLS for caching.
    - **Ingress:** Enabled with `nginx` ingress class and SSL redirection.
    - **Email:** Configured for SMTP relay.

### Authentik Remote Cluster

- **Name:** `default--authentik-remote-cluster`
- **Chart:** `authentik-remote-cluster`
- **Version:** `2.0.0`
- **Release Name:** `authentik-remote-cluster-default`
- **Namespace:** `default`
- **Update Interval:** 5 minutes
- **Dependencies:** `authentik--authentik`
- **Values Configuration:**
  - Cluster role enabled.
  - Service account secret disabled.

### Patroni (PostgreSQL)

- **Name:** `authentik--authentik-patroni`
- **Chart:** `patroni`
- **Version:** Floating (`>=0.1.0-0`)
- **Release Name:** `authentik-patroni`
- **Namespace:** `authentik`
- **Update Interval:** 5 minutes
- **Dependencies:**
  - `cert-manager--cert-manager`
  - `reflector--reflector`
  - `etcd--etcd`
- **Values Configuration:**
  - PostgreSQL database `authentik` with user `authentik`.
  - Patroni cluster with 2 replicas and TLS enabled.
  - Pgbouncer enabled for connection pooling.
  - Backup scripts and persistence configured.

### Redis

- **Name:** `authentik--authentik-redis`
- **Chart:** Redis (details truncated in input)
- **Namespace:** `authentik`
- **Purpose:** Provides caching services for Authentik.

## Image Management

### Authentik Server

- **Image Repository:** `ghcr.io/goauthentik/server`
- **Policy:** Semantic versioning (`x.x.x`)
- **Update Interval:** 24 hours

### Patroni

- **Image Repository:** `ghcr.io/wahooli/docker/patroni-17`
- **Policy:** Semantic versioning (`x.x.x`)
- **Update Interval:** 24 hours

## HTTPRoute

Authentik is exposed via HTTPRoute:

- **Hostnames:**
  - `auth.wahoo.li`
  - `auth.absolutist.it`
  - `authentik.wahoo.li`
  - `authentik.absolutist.it`
- **Parent Gateway:** `internal-gw` in the `infrastructure` namespace.
- **Backend Service:** `authentik-server` on port `80`.

## Additional Notes

- **Monitoring:** Metrics are enabled for the Authentik server but disabled for PostgreSQL and Redis.
- **Security:** TLS is enforced for database and caching connections.
- **Backup:** Velero annotations are configured for backup and restore operations.
- **Ingress Annotations:** Includes SSL redirection and custom HTTP error handling.

For further details, refer to the Helm chart documentation at [Authentik Helm Charts](https://charts.goauthentik.io/).
