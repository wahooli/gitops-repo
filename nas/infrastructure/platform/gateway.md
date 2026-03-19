---
title: "gateway"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# Gateway

## Overview
The `gateway` component provides ingress capabilities for the `nas` cluster by defining a `Gateway` resource and associated `HTTPRoute` for routing external traffic to internal services. It leverages the `cilium` GatewayClass for advanced networking features, including direct server return (DSR) and load balancing. This component also integrates with `cert-manager` for TLS termination and `external-dns` for DNS management.

## Resource Glossary

### Networking
1. **Gateway (`internal-gw`)**
   - **Namespace**: `infrastructure`
   - **Purpose**: Acts as the central ingress point for external traffic into the cluster.
   - **Key Features**:
     - Uses the `cilium` GatewayClass for advanced networking capabilities.
     - Configured with multiple listeners for HTTP and HTTPS traffic on ports 80 and 443, respectively.
     - Supports hostname-based routing for two domains: `*.absolutist.it` and `*.wahoo.li`.
     - TLS termination is enabled for HTTPS traffic using certificates stored in Kubernetes Secrets (`wahooli-wildcard-tls` and `absolutistit-wildcard-tls`).
     - Annotations for `external-dns` to manage DNS records and `lbipam.cilium.io` for IP address allocation.

2. **HTTPRoute (`https-redirect-filter`)**
   - **Namespace**: `infrastructure`
   - **Purpose**: Redirects HTTP traffic to HTTPS for improved security.
   - **Key Features**:
     - Applies to hostnames `*.absolutist.it` and `*.wahoo.li`.
     - Redirects HTTP traffic from the `internal-wahooli-http` and `internal-absolutistit-http` listeners to their HTTPS counterparts using a 301 status code.

## Configuration Highlights
- **TLS Certificates**:
  - HTTPS traffic for `*.wahoo.li` is terminated using the `wahooli-wildcard-tls` Secret.
  - HTTPS traffic for `*.absolutist.it` is terminated using the `absolutistit-wildcard-tls` Secret.
- **DNS Management**:
  - The `external-dns.alpha.kubernetes.io/hostname` annotation dynamically manages DNS records for the domains `gw.nas.absolutist.it` and `gw.nas.wahoo.li`.
- **Load Balancer Configuration**:
  - The `lbipam.cilium.io/ips` annotation specifies the IP address for the internal gateway load balancer.
  - The `service.cilium.io/forwarding-mode` annotation enables direct server return (DSR) mode for efficient traffic routing.
- **Allowed Routes**:
  - Only routes from namespaces with the label `internal-services: "true"` are permitted.

## Deployment
- **Namespace**: `infrastructure`
- **Gateway Name**: `internal-gw`
- **Reconciliation**: Managed by Flux with the `infrastructure-platform` Kustomization in the `flux-system` namespace.
- **Configurable Parameters**:
  - `${domain_absolutist_it}`: Domain for `absolutist.it`.
  - `${domain_wahoo_li}`: Domain for `wahoo.li`.
  - `${internal_gw_lb_ip}`: Load balancer IP address for the internal gateway.

This component is critical for managing external traffic ingress, ensuring secure communication via HTTPS, and integrating with DNS and certificate management systems.
