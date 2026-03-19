---
title: "default-backend"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# default-backend

The `default-backend` component provides a simple Nginx-based backend service for handling HTTP requests. It is deployed in the `infrastructure` namespace of the `tpi-1` Kubernetes cluster.

## Overview

This component includes the following Kubernetes resources:
- **Service**: A ClusterIP service for internal communication.
- **Deployment**: A single-replica Nginx deployment with resource constraints.
- **Ingress**: Multiple ingress rules for routing traffic to specific paths and hosts.
- **ConfigMaps**: Configuration and static content for Nginx.

## Deployment Details

### Service

- **Name**: `default-backend`
- **Namespace**: `infrastructure`
- **Type**: ClusterIP
- **Ports**:
  - `http`: Port 80 (TCP)
- **Selector**:
  - `app.kubernetes.io/instance`: `default-backend`
  - `app.kubernetes.io/name`: `nginx`

### Deployment

- **Name**: `default-nginx-backend`
- **Namespace**: `infrastructure`
- **Replicas**: 1
- **Image**: `nginx:1.27.3`
- **Resource Requests**:
  - CPU: 64m
  - Memory: 32Mi
- **Resource Limits**:
  - CPU: 250m
  - Memory: 64Mi
- **Probes**:
  - **Liveness Probe**: TCP socket on port 80
  - **Readiness Probe**: TCP socket on port 80
- **Volumes**:
  - `nginx-html`: Populated from a ConfigMap (`nginx-html-88226kt59t`)
  - `nginx-confd`: Populated from a ConfigMap (`nginx-config-kd7f58gtc8`)
  - `html`: EmptyDir for serving static content
- **Init Container**:
  - **Name**: `webcontent-copy`
  - **Image**: `busybox:1.37.0`
  - **Command**: Copies files from `nginx-html` to `html` volume.

### Ingress Rules

#### Overrides Ingress

- **Name**: `overrides-ingress`
- **Namespace**: `infrastructure`
- **Ingress Class**: `nginx`
- **Annotations**:
  - `external-dns.alpha.kubernetes.io/exclude`: `"true"`
  - `nginx.ingress.kubernetes.io/custom-http-errors`: `"404"`
  - `nginx.ingress.kubernetes.io/force-ssl-redirect`: `"true"`
- **Rules**:
  Routes traffic to `/admin`, `/metrics`, and `/setup` paths for various subdomains (e.g., `vault.wahoo.li`, `jellyfin.wahoo.li`, etc.).

#### Robots.txt Ingress

- **Name**: `robots-txt`
- **Namespace**: `infrastructure`
- **Ingress Class**: `nginx`
- **Annotations**:
  - `external-dns.alpha.kubernetes.io/exclude`: `"true"`
  - `nginx.ingress.kubernetes.io/access-log-filter`: `"true"`
  - `nginx.ingress.kubernetes.io/custom-http-errors`: `"404"`
  - `nginx.ingress.kubernetes.io/force-ssl-redirect`: `"true"`
- **Rules**:
  Routes traffic to `/robots.txt` and `/ads.txt` paths for multiple subdomains (e.g., `auth.wahoo.li`, `sonarr.wahoo.li`, etc.).

#### Static Backend Ingress

- **Name**: `static-backend`
- **Namespace**: `infrastructure`
- **Ingress Class**: `nginx`
- **Annotations**:
  - `external-dns.alpha.kubernetes.io/cloudflare-proxied`: `"false"`
  - `external-dns.alpha.kubernetes.io/target`: `gw.wahoo.li`
  - `nginx.ingress.kubernetes.io/access-log-filter`: `"true"`
  - `nginx.ingress.kubernetes.io/force-ssl-redirect`: `"true"`
  - `nginx.ingress.kubernetes.io/rewrite-target`: `/$2`
- **Rules**:
  Routes traffic to `/()(.*)` paths for `static.wahoo.li`.

### ConfigMaps

#### Static Content ConfigMap

- **Name**: `nginx-html-88226kt59t`
- **Namespace**: `infrastructure`
- **Data**:
  - `404.html`: Custom HTML template for 404 errors.
  - `font-awesome.min.css`: Font Awesome stylesheet.

#### Nginx Configuration ConfigMap

- **Name**: `nginx-config-kd7f58gtc8`
- **Namespace**: `infrastructure`
- **Purpose**: Provides Nginx configuration files.

## Notes

- The Nginx image version is pinned to `1.27.3`.
- The `busybox` image version is pinned to `1.37.0`.
- Ingress rules dynamically reference the `wahoo.li` domain and its subdomains.
- SSL redirection is enforced for all ingress rules.
- Static content and configuration are managed via ConfigMaps.
