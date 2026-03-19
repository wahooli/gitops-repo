---
title: "gateway"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# Gateway

## Overview

The `gateway` component provides ingress capabilities for the `tpi-1` cluster, enabling HTTP and HTTPS traffic routing for internal services. It is implemented using the Kubernetes Gateway API and leverages the Cilium GatewayClass for advanced networking features. This component is configured to handle traffic for two domains (`absolutist.it` and `wahoo.li`) with support for TLS termination and HTTP-to-HTTPS redirection.

## Resource Glossary

### Networking

#### Gateway
- **Name:** `internal-gw`
- **Namespace:** `infrastructure`
- **Purpose:** Acts as the entry point for HTTP and HTTPS traffic into the cluster. Configured with the `cilium` GatewayClass and supports advanced networking features like Direct Server Return (DSR) and LoadBalancer IP allocation.
- **Key Features:**
  - Handles traffic for two domains: `*.absolutist.it` and `*.wahoo.li`.
  - TLS termination using certificates stored in Secrets (`wahooli-wildcard-tls` and `absolutistit-wildcard-tls`).
  - Configured with multiple listeners:
    - HTTP (port 80) and HTTPS (port 443) for both domains.
    - Restricts routing to namespaces with the label `internal-services: "true"`.

#### HTTPRoute
- **Name:** `https-redirect-filter`
- **Namespace:** `infrastructure`
- **Purpose:** Implements HTTP-to-HTTPS redirection for both domains.
- **Key Features:**
  - Matches HTTP traffic for `*.absolutist.it` and `*.wahoo.li`.
  - Redirects requests to HTTPS with a 301 status code.
  - Associated with the HTTP listeners of the `internal-gw` Gateway.

## Configuration Highlights

- **TLS Certificates:**
  - TLS termination is enabled for HTTPS traffic.
  - Certificates are referenced from Secrets:
    - `wahooli-wildcard-tls` for `*.wahoo.li`.
    - `absolutistit-wildcard-tls` for `*.absolutist.it`.
  - Certificates are issued by the `letsencrypt-production` ClusterIssuer (via cert-manager).

- **Domain Configuration:**
  - The component supports two domains:
    - `*.absolutist.it` (configurable via `${domain_absolutist_it}`).
    - `*.wahoo.li` (configurable via `${domain_wahoo_li}`).

- **Load Balancer Configuration:**
  - The Gateway uses the `cilium` GatewayClass with the following annotations:
    - `lbipam.cilium.io/ips`: Configurable via `${internal_gw_lb_ip}`.
    - `service.cilium.io/forwarding-mode`: Set to `dsr` for Direct Server Return.
    - `service.cilium.io/type`: Set to `LoadBalancer`.

## Deployment

- **Target Namespace:** `infrastructure`
- **Reconciliation:** Managed by Flux with the `infrastructure-platform` Kustomization.
- **Annotations:**
  - `cert-manager.io/cluster-issuer: letsencrypt-production` for automatic certificate management.
  - External DNS annotations for automatic DNS record management:
    - `gw.tpi-1.${domain_absolutist_it}`.
    - `gw.tpi-1.${domain_wahoo_li}`.
