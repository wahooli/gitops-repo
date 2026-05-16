---
title: "forgejo"
parent: "Apps"
grand_parent: "nas"
---

# forgejo

## Overview
Forgejo is a self-hosted Git service that provides a collaborative platform for software development. This deployment includes additional components such as Redis for caching and Patroni for PostgreSQL clustering.

## Deployment Details
The Forgejo component is deployed in the `forgejo` namespace and is managed using Flux CD with Helm. The current version of the Forgejo chart is **16.2.1**.

### Helm Releases
The deployment consists of the following Helm releases:

#### 1. Forgejo
- **Release Name:** `forgejo`
- **Namespace:** `forgejo`
- **Chart Version:** `16.2.1`
- **Source Repository:** `oci://code.forgejo.org/forgejo-helm`
- **Dependencies:**
  - Redis (`forgejo--forgejo-redis`)
  - Patroni (`forgejo--forgejo-patroni`)
  - SeaweedFS (`seaweedfs--seaweedfs`)
- **Install Interval:** 5 minutes
- **Values Configuration:** Loaded from multiple ConfigMaps, including base and shared values.

#### 2. Redis
- **Release Name:** `forgejo-redis`
- **Namespace:** `forgejo`
- **Chart Version:** `>=0.1.0-0`
- **Source Repository:** `wahooli`
- **Install Interval:** 5 minutes
- **Values Configuration:** Loaded from a ConfigMap with shared values for Redis.

#### 3. Patroni
- **Release Name:** `forgejo-patroni`
- **Namespace:** `forgejo`
- **Chart Version:** `>=0.1.0-0`
- **Source Repository:** `wahooli`
- **Install Interval:** 5 minutes
- **Values Configuration:** Loaded from a ConfigMap with shared values for Patroni.

## Services
### Forgejo SSH Load Balancer
- **Service Type:** LoadBalancer
- **Ports:**
  - SSH: 22
  - SSH Proxy: 2222
- **Annotations:** Configured for external DNS and Cilium.

### HTTP Routes
Two HTTP routes are configured for Forgejo:
1. **Public Route**: Exposes the Forgejo application on `git.${domain_wahoo_li}`.
2. **Private Route**: Used for internal communication within the cluster.

## Configuration
The configuration for Forgejo is extensive and includes settings for:
- **Service Accounts**
- **Persistence**
- **OAuth2 Integration**
- **Database Connection**
- **Storage Options** (using MinIO via SeaweedFS)
- **Logging and Metrics**

### Example Configuration Snippet
```yaml
service:
  http:
    type: ClusterIP
    port: 3000
  ssh:
    type: ClusterIP
    port: 22
```

## Image Repositories
The following images are used in the deployment:
- **Forgejo**: `code.forgejo.org/forgejo/forgejo:15.0.1-rootless`
- **Syncthing**: `syncthing/syncthing:2.0.16`
- **Anubis**: `ghcr.io/techarohq/anubis:v1.25.0`

## Notes
- The deployment is configured to use Redis for caching and session management.
- The application is set to run in production mode with various security and performance optimizations.
- Ensure that the necessary secrets and ConfigMaps are created and available in the `forgejo` namespace for the deployment to function correctly.
