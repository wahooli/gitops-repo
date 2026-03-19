---
title: "haproxy"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# HAProxy

## Overview

The `haproxy` component provides a highly available and performant reverse proxy and load balancer for the `tpi-1` Kubernetes cluster. It is deployed using a HelmRelease managed by Flux and is configured to handle HTTPS traffic with SSL termination, HTTP-to-HTTPS redirection, and advanced load balancing features. This deployment also includes support for WebSocket connections, compression, and custom security headers.

## Dependencies

The `haproxy` HelmRelease depends on the `cert-manager--cert-manager` HelmRelease. This dependency ensures that SSL certificates are managed and issued by the `cert-manager` component, which is required for HTTPS traffic handling by HAProxy.

## Helm Chart(s)

- **Chart Name**: `haproxy`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `haproxy`
- **Target Namespace**: `haproxy`

## Resource Glossary

### Networking
- **Service (`haproxy`)**: 
  - Type: `ClusterIP`
  - Ports:
    - HTTP: Port 80
    - HTTPS: Port 443
    - Stats: Port 8404
  - Annotations:
    - `external-dns.alpha.kubernetes.io/hostname`: Configures external DNS for the HAProxy service to respond to requests for `haproxy.tpi-1.absolutist.it` and `haproxy.tpi-1.wahoo.li`.

### Workloads
- **Deployment (`haproxy`)**:
  - Replicas: 1
  - Security Context:
    - `fsGroup`: 99
    - `runAsGroup`: 99
    - `runAsUser`: 99
    - `net.ipv4.ip_unprivileged_port_start`: 0
  - Init Containers:
    - `combine-certs`: Combines the TLS key and certificate into a single `.pem` file for use by HAProxy.
  - Annotations:
    - `secret.reloader.stakater.com/reload`: Ensures that the deployment is reloaded when the `haproxy-wildcard` secret changes.

### Configuration
- **ConfigMap (`haproxy-config`)**:
  - Contains the HAProxy configuration file (`haproxy.cfg`) with settings for:
    - Global configurations (e.g., logging, SSL parameters, connection limits).
    - Frontend and backend configurations for handling HTTP, HTTPS, and WebSocket traffic.
    - Security headers and caching rules for static files.
    - Load balancing and health check settings for backend servers.

### Image Management
- **ImageRepository (`haproxy`)**:
  - Image: `docker.io/haproxy`
  - Interval: 24h
- **ImagePolicy (`haproxy-3-2`)**:
  - Policy: Semantic versioning (`3.2.x`)
  - Ensures that the HAProxy image tag adheres to the specified version range.

### Namespace
- **Namespace (`haproxy`)**:
  - Dedicated namespace for the HAProxy component.
  - Includes a label to exclude it from TopoLVM webhook processing.

## Configuration Highlights

- **Image**: The HAProxy deployment uses the `haproxy` image with a tag managed by the `haproxy-3-2` ImagePolicy. The current tag is `3.2.14`.
- **SSL Configuration**:
  - SSL certificates are managed by `cert-manager` and stored in the `haproxy-wildcard` secret.
  - An init container combines the TLS key and certificate into a `.pem` file for use by HAProxy.
  - SSL settings include strong ciphers and protocols, with a minimum version of TLS 1.2.
- **Service Configuration**:
  - The main service is of type `LoadBalancer` with `externalTrafficPolicy` set to `Local` for preserving client IPs.
  - External DNS annotations are configured for domain names `haproxy.tpi-1.absolutist.it` and `haproxy.tpi-1.wahoo.li`.
- **Persistence**:
  - Persistent volumes are used to store SSL certificates and TLS secrets.
  - Certificates are mounted at `/etc/haproxy/certs`, and TLS secrets are mounted at `/mnt/secret`.
- **Custom Headers**:
  - Security headers such as `X-Content-Type-Options`, `X-Frame-Options`, and `Cache-Control` for static files are configured.
- **WebSocket Support**:
  - WebSocket connections are identified and handled with specific headers and timeouts.
- **Compression**:
  - Compression is enabled for specific content types (e.g., text, JSON, JavaScript).

## Deployment

- **Target Namespace**: `haproxy`
- **Release Name**: `haproxy`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**:
  - Automatic retries for failed installations or upgrades (`retries: -1`).

This deployment is managed by Flux and uses a floating Helm chart version (`latest`), ensuring that updates to the chart are automatically applied during reconciliation. Configuration values are sourced from multiple ConfigMaps, allowing for flexible and modular customization.
