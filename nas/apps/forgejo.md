---
title: "forgejo"
parent: "Apps"
grand_parent: "nas"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a lightweight alternative to GitHub, GitLab, and Gitea. This deployment includes necessary components such as Redis for caching and Patroni for PostgreSQL high availability.

## Deployment Details
The Forgejo deployment in the `nas` cluster consists of the following Helm releases:

### 1. Forgejo
- **Release Name:** `forgejo`
- **Chart Version:** `16.2.1`
- **Namespace:** `forgejo`
- **Source Repository:** `oci://code.forgejo.org/forgejo-helm`
- **Image:** `code.forgejo.org/forgejo/forgejo:14.0.3-rootless`
- **Configuration:**
  - **Service Type:** ClusterIP for HTTP and SSH services.
  - **Persistence:** Enabled with a size of 10Gi.
  - **OAuth Configuration:** Integrated with Authentik for OpenID Connect.
  - **Database:** PostgreSQL via Patroni with SSL mode enabled.
  - **Liveness and Readiness Probes:** Configured for health checks.

### 2. Redis
- **Release Name:** `forgejo-redis`
- **Chart Version:** `>=0.1.0-0`
- **Namespace:** `forgejo`
- **Configuration:**
  - **Sentinel:** Enabled for high availability.
  - **Persistence:** Enabled with a size of 1Gi.

### 3. Patroni
- **Release Name:** `forgejo-patroni`
- **Chart Version:** `>=0.1.0-0`
- **Namespace:** `forgejo`
- **Configuration:**
  - **PostgreSQL Database:** Bootstrap with database name `forgejo` and user credentials sourced from secrets.
  - **Replica Count:** 2 for high availability.

## Services
- **SSH Load Balancer:**
  - **Type:** LoadBalancer
  - **Ports:** 
    - 22 (SSH)
    - 2222 (SSH Proxy)
  
- **HTTP Routes:**
  - **Public Route:** Exposes Forgejo on `git.${domain_wahoo_li:=wahoo.li}` for HTTP traffic.
  - **Private Route:** Allows internal access to Forgejo.

## Image Repositories
- **Forgejo Image Repository:** `code.forgejo.org/forgejo/forgejo`
- **Syncthing Image Repository:** `syncthing/syncthing:2.0.15`
- **Anubis Image Repository:** `ghcr.io/techarohq/anubis:v1.25.0`

## Configuration Management
Configuration values are sourced from multiple ConfigMaps:
- `forgejo-values-hhd865hht2` for base and shared values.
- `forgejo-redis-values-gfkgt5gh59` for Redis configuration.
- `forgejo-patroni-values-t7c846kbfk` for Patroni configuration.

## Security Policies
- **Private IP Allow Policy:** Restricts access to the private HTTP route to specific CIDR ranges.

## Notes
- The deployment is configured to automatically update images and Helm charts every 24 hours.
- Health checks are configured to ensure the application is running smoothly and can recover from failures.
