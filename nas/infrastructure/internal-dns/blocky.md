---
title: "blocky"
parent: "Infrastructure / Internal-dns"
grand_parent: "nas"
---

# Blocky

Blocky is a DNS proxy and ad-blocking solution deployed in the `nas` cluster. This document outlines the configuration and deployment details for the Blocky component.

## Overview

Blocky is deployed using a HelmRelease managed by FluxCD. It provides DNS resolution services with advanced features such as caching, blocking, and conditional forwarding. The deployment includes persistent configuration storage, TLS support, and Prometheus metrics for monitoring.

## Deployment Details

### HelmRelease

- **Name**: `internal-dns--blocky`
- **Namespace**: `flux-system`
- **Chart**: `blocky`
- **Chart Version**: `>=0.1.0-0`
- **Source Repository**: `wahooli` (HelmRepository in `flux-system` namespace)
- **Release Name**: `blocky`
- **Target Namespace**: `internal-dns`
- **Interval**: 5 minutes
- **Dependencies**:
  - `cert-manager--cert-manager`
  - `internal-dns--bind9`
  - `internal-dns--unbound`

### Image Details

- **Repository**: `ghcr.io/0xerr0r/blocky`
- **Tag**: `v0.29.0` (managed by Flux ImagePolicy)

### Configuration

The configuration for Blocky is managed using ConfigMaps and includes the following:

#### Base Values (`values-base.yaml`)

- **Image Repository**: `ghcr.io/0xerr0r/blocky`
- **Environment Variables**:
  - `TZ`: `Europe/Helsinki`
- **DNS Configuration**:
  - `ndots`: `1`

#### Main Values (`values.yaml`)

- **Image Tag**: `v0.29.0`
- **PodMonitor**:
  - Enabled: `true`
  - Job Label: `app.kubernetes.io/name`
- **Service Configuration**:
  - **Main Service**:
    - `externalTrafficPolicy`: `Local`
    - `type`: `LoadBalancer`
    - `clusterIP`: `${blocky_cluster_ip}`
    - Annotations:
      - `lbipam.cilium.io/ips`: `${dns_ip_addr_1},${dns_ip_addr_2},8.8.8.8,8.8.4.4`
      - `service.cilium.io/global`: `true`
      - `service.cilium.io/affinity`: `local`
  - **NAS Service**:
    - Annotations:
      - `service.cilium.io/global`: `true`
      - `service.cilium.io/affinity`: `local`
    - Type: `ClusterIP`
    - Ports: Inherited from Main Service
- **Persistence**:
  - Configuration:
    - Enabled: `true`
    - Mounts:
      - `/app/config.yml`
      - `/app/tlds-alpha-by-domain.txt`
      - `/app/ads-whitelist.txt`
      - `/app/manual-blocklist.txt`
    - ConfigMap: `blocky-config`
  - TLS Certificates:
    - Enabled: `true`
    - Mount Path: `/app/certs/`
    - Secret: `tls-blocky`
    - Default Mode: `0444`
- **Workload Annotations**:
  - `secret.reloader.stakater.com/reload`: `tls-blocky`
- **Resources**: Not specified

#### Extra Values (`values-extra.yaml`)

- **Service Configuration**:
  - **NAS Service**:
    - Annotations:
      - `service.cilium.io/global`: `true`
      - `service.cilium.io/affinity`: `local`
    - Type: `ClusterIP`
    - Ports: Inherited from Main Service

### ConfigMap

The configuration for Blocky is stored in a ConfigMap named `blocky-values-7k5ht6d88m` in the `flux-system` namespace. It includes:

- **Base Values**: `values-base.yaml`
- **Main Values**: `values.yaml`
- **Optional Extra Values**: `values-extra.yaml`

### Certificate Management

Blocky uses a TLS certificate for secure communication:

- **Certificate Name**: `blocky-doh`
- **Namespace**: `internal-dns`
- **DNS Names**:
  - `ns1.${domain_wahoo_li:=wahoo.li}`
  - `ns2.${domain_absolutist_it:=absolutist.it}`
  - `ns.${domain_wahoo_li:=wahoo.li}`
  - `ns.${domain_absolutist_it:=absolutist.it}`
  - `dns.${domain_wahoo_li:=wahoo.li}`
  - `dns.${domain_absolutist_it:=absolutist.it}`
- **Issuer**: `${certificate_cluster_issuer:=letsencrypt-production}`
- **Secret Name**: `tls-blocky`

### Image Automation

- **ImagePolicy**:
  - **Name**: `blocky`
  - **Namespace**: `flux-system`
  - **Filter Tags**:
    - Pattern: `v(?P<major>\d+)\.(?P<minor>\d+)\.?(?P<patch>\d+)?`
    - Extraction: `$major$minor$patch`
  - **Policy**: Numerical (ascending order)

### Prometheus Metrics

- **Enabled**: `true`
- **Path**: `/metrics`

### Persistence

Blocky uses a ConfigMap named `blocky-config` for its configuration and a Secret named `tls-blocky` for TLS certificates. The configuration includes:

- DNS bootstrap and upstream settings
- Custom DNS mappings
- Conditional forwarding rules
- Blacklists and whitelists for blocking and allowing specific domains
- Caching settings
- Logging configuration
- Prometheus metrics endpoint

### Ports

- **DNS**: `53`
- **DNS-over-TLS (DoT)**: `853`
- **HTTPS**: `443`
- **HTTP**: `4000`

## Monitoring

Blocky is configured with a Prometheus `PodMonitor` for monitoring DNS metrics. Metrics are exposed at the `/metrics` endpoint.

## Notes

- The deployment depends on other DNS components (`bind9`, `unbound`) and `cert-manager`.
- The `blocky` image tag is managed by Flux ImagePolicy, ensuring it stays up-to-date with the latest version matching the specified policy.
- The deployment uses a combination of static and dynamic configuration values sourced from multiple ConfigMaps.
- TLS certificates are managed by cert-manager and stored in the `tls-blocky` secret.

For further details, refer to the configuration files in the `flux-system` namespace.
