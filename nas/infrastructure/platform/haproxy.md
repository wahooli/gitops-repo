---
title: "haproxy"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# HAProxy

## Overview

The `haproxy` component provides a highly available, reliable, and performant load balancer for the Kubernetes cluster. It is deployed using a Helm chart and is configured to handle HTTP, HTTPS, and WebSocket traffic. This component is designed to manage traffic routing, SSL termination, and load balancing for backend services within the cluster. It also integrates with external DNS and certificate management systems to provide secure and reliable service.

## Dependencies

The `haproxy` component depends on the `cert-manager--cert-manager` HelmRelease. This dependency ensures that SSL/TLS certificates are managed and issued automatically using a `ClusterIssuer` from the cert-manager.

## Helm Chart(s)

- **Chart Name**: `haproxy`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `haproxy`
- **Target Namespace**: `haproxy`

## Resource Glossary

### Networking
- **Service**: 
  - Name: `haproxy`
  - Type: `ClusterIP`
  - Ports:
    - `http` (80/TCP)
    - `https` (443/TCP)
    - `stats` (8404/TCP)
  - Provides network access to the HAProxy load balancer and exposes the stats endpoint.

### Workload
- **Deployment**: 
  - Name: `haproxy`
  - Replicas: `1`
  - Strategy: `RollingUpdate`
  - Security Context:
    - `fsGroup`: `99`
    - `runAsGroup`: `99`
    - `runAsUser`: `99`
  - Includes an init container (`combine-certs`) to combine TLS key and certificate files into a single `.pem` file for SSL termination.

### Configuration
- **ConfigMap**: 
  - Name: `haproxy-config`
  - Contains the HAProxy configuration (`haproxy.cfg`) for global settings, frontend, and backend definitions, including SSL settings, security headers, and compression rules.

### Image Management
- **ImageRepository**: 
  - Name: `haproxy`
  - Image: `docker.io/haproxy`
  - Update Interval: `24h`
- **ImagePolicy**: 
  - Name: `haproxy-3-2`
  - Policy: Semantic versioning (`3.2.x`)

### Namespace
- **Namespace**: 
  - Name: `haproxy`
  - Labels include `topolvm.io/webhook: ignore` to exclude it from certain webhook operations.

## Configuration Highlights

- **SSL/TLS**: 
  - Certificates are managed using a `ClusterIssuer` from cert-manager.
  - A wildcard certificate is generated for domains under `${domain_wahoo_li:=wahoo.li}`.
  - SSL termination is handled by HAProxy, with strong cipher suites and TLSv1.2+ enforced.
- **Service Configuration**:
  - External traffic policy is set to `Local` for improved performance.
  - Service annotations include external DNS configuration for domains `${domain_absolutist_it:=absolutist.it}` and `${domain_wahoo_li:=wahoo.li}`.
- **Persistence**:
  - Persistent volumes are used to store certificates and TLS secrets.
  - Certificates are mounted at `/etc/haproxy/certs`.
- **Security Headers**:
  - HAProxy sets various security headers, including `X-Content-Type-Options`, `X-Frame-Options`, and `Cache-Control`.
  - Sensitive headers like `X-Powered-By` and `Server` are removed from responses.
- **WebSocket Support**:
  - WebSocket connections are identified and handled with appropriate headers and timeouts.
- **Compression**:
  - Gzip compression is enabled for specific content types, such as `text/html` and `application/json`.

## Deployment

- **Target Namespace**: `haproxy`
- **Release Name**: `haproxy`
- **Reconciliation Interval**: `5m`
- **Install/Upgrade Behavior**:
  - Unlimited retries for remediation in case of installation failures.
  - Configurable values are sourced from multiple ConfigMaps, allowing for flexible customization.

This deployment ensures a robust and secure load balancing solution for the Kubernetes cluster, with support for SSL termination, WebSocket handling, and integration with external DNS and certificate management systems.
