---
title: "default-backend"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# default-backend

The `default-backend` component is a Kubernetes deployment that provides a default backend service using NGINX. It is deployed in the `infrastructure` namespace of the `nas` cluster. This component serves as a fallback or static content handler for various ingress rules.

---

## Overview

The `default-backend` component consists of the following Kubernetes resources:

- **Service**: Exposes the NGINX deployment as a `ClusterIP` service.
- **Deployment**: Runs the NGINX container with a single replica.
- **Ingress**: Configures multiple ingress rules for routing traffic to the default backend.
- **ConfigMap**: Provides static content and configuration for the NGINX server.

---

## Deployment Details

### Namespace
- **Namespace**: `infrastructure`

### Service
- **Name**: `default-backend`
- **Type**: `ClusterIP`
- **Ports**:
  - `http`: Port 80 (TCP)
- **Selector**:
  - `app.kubernetes.io/instance`: `default-backend`
  - `app.kubernetes.io/name`: `nginx`

### Deployment
- **Name**: `default-nginx-backend`
- **Replicas**: 1
- **Container**:
  - **Image**: `nginx:1.27.3`
  - **Ports**:
    - `http`: Port 80 (TCP)
  - **Resources**:
    - **Requests**: CPU: `64m`, Memory: `32Mi`
    - **Limits**: CPU: `250m`, Memory: `64Mi`
  - **Probes**:
    - **Liveness Probe**: TCP socket on port 80, checks every 10 seconds
    - **Readiness Probe**: TCP socket on port 80, checks every 5 seconds
  - **Volume Mounts**:
    - `/usr/share/nginx/html`: Mounted from `html` volume
    - `/etc/nginx/conf.d`: Mounted from `nginx-confd` volume
- **Init Container**:
  - **Name**: `webcontent-copy`
  - **Image**: `busybox:1.37.0`
  - **Command**: Copies static content from `nginx-html` volume to `html` volume
  - **Volume Mounts**:
    - `/src`: Mounted from `nginx-html` volume
    - `/dest`: Mounted from `html` volume
- **Volumes**:
  - `nginx-html`: Populated by `nginx-html-88226kt59t` ConfigMap
  - `nginx-confd`: Populated by `nginx-config-kd7f58gtc8` ConfigMap
  - `html`: EmptyDir volume for serving static content

---

## Ingress Configuration

### Ingress: `overrides-ingress`
- **Ingress Class**: `nginx`
- **Annotations**:
  - `external-dns.alpha.kubernetes.io/exclude`: `"true"`
  - `nginx.ingress.kubernetes.io/custom-http-errors`: `"404"`
  - `nginx.ingress.kubernetes.io/force-ssl-redirect`: `"true"`
- **Rules**:
  - `vault.${domain_wahoo_li:=wahoo.li}`:
    - `/admin` → `default-backend:80`
  - `paperless.${domain_wahoo_li:=wahoo.li}`:
    - `/admin` → `default-backend:80`
  - `jellyfin.${domain_wahoo_li:=wahoo.li}`:
    - `/metrics` → `default-backend:80`
  - `overseerr.${domain_wahoo_li:=wahoo.li}`:
    - `/setup` → `default-backend:80`

### Ingress: `robots-txt`
- **Ingress Class**: `nginx`
- **Annotations**:
  - `external-dns.alpha.kubernetes.io/exclude`: `"true"`
  - `nginx.ingress.kubernetes.io/access-log-filter`: `"true"`
  - `nginx.ingress.kubernetes.io/custom-http-errors`: `"404"`
  - `nginx.ingress.kubernetes.io/force-ssl-redirect`: `"true"`
- **Rules**:
  - Hosts include `${domain_wahoo_li:=wahoo.li}`, `auth.${domain_wahoo_li:=wahoo.li}`, `ombi.${domain_wahoo_li:=wahoo.li}`, and more.
  - Paths:
    - `/robots.txt` → `default-backend:80`
    - `/ads.txt` → `default-backend:80`

### Ingress: `static-backend`
- **Ingress Class**: `nginx`
- **Annotations**:
  - `external-dns.alpha.kubernetes.io/cloudflare-proxied`: `"false"`
  - `external-dns.alpha.kubernetes.io/target`: `gw.${domain_wahoo_li:=wahoo.li}`
  - `nginx.ingress.kubernetes.io/access-log-filter`: `"true"`
  - `nginx.ingress.kubernetes.io/force-ssl-redirect`: `"true"`
  - `nginx.ingress.kubernetes.io/rewrite-target`: `/$2`
- **Rules**:
  - `static.${domain_wahoo_li:=wahoo.li}`:
    - `/()(.*)` → `default-backend:80`

---

## ConfigMap
- **Name**: `nginx-html-88226kt59t`
- **Static Content**:
  - `404.html`: Custom 404 error page
  - `font-awesome.min.css`: Font Awesome CSS for styling

---

## Summary

The `default-backend` component provides a default NGINX-based backend service with static content and custom error pages. It is configured with multiple ingress rules to handle specific paths and hosts. The deployment uses the `nginx:1.27.3` image and includes resource limits and probes for health checks. Static content and configuration are managed via ConfigMaps.
