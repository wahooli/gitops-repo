---
title: "blocky"
parent: "Infrastructure / Internal-dns"
grand_parent: "tpi-1"
---

# Blocky

Blocky is a DNS proxy and ad-blocker deployed in the `tpi-1` Kubernetes cluster. It is managed using Flux and HelmRelease. This document provides an overview of the deployment configuration and key features.

## Overview

- **Cluster**: `tpi-1`
- **Namespace**: `internal-dns`
- **Helm Chart**: `blocky` (version: `>=0.1.0-0`)
- **Image Repository**: `ghcr.io/0xerr0r/blocky`
- **Image Tag**: `v0.29.0`
- **Release Name**: `blocky`
- **Chart Source**: HelmRepository `wahooli` in namespace `flux-system`
- **Dependencies**:
  - `cert-manager--cert-manager`
  - `internal-dns--bind9`
  - `internal-dns--unbound`

---

## Deployment Details

### HelmRelease Configuration

- **Chart Interval**: 24h
- **Install Remediation**: Unlimited retries
- **Sync Interval**: 5m
- **Target Namespace**: `internal-dns`
- **Values Sources**:
  - `blocky-values-bcf8m6kfk4` ConfigMap:
    - `values-base.yaml`
    - `values.yaml`
    - `values-extra.yaml` (optional)

### Persistence

- Configuration is stored in a ConfigMap named `blocky-config`.
- Persistent volumes are used for the following files:
  - `/app/config.yml`
  - `/app/tlds-alpha-by-domain.txt`
  - `/app/ads-whitelist.txt`
  - `/app/manual-blocklist.txt`

### TLS Configuration

- TLS certificates are managed by `cert-manager`.
- Certificate resource:
  - **Name**: `blocky-doh`
  - **Namespace**: `internal-dns`
  - **Issuer**: `${certificate_cluster_issuer:=letsencrypt-production}`
  - **Secret Name**: `tls-blocky`
  - **DNS Names**:
    - `ns1.${domain_wahoo_li:=wahoo.li}`
    - `ns2.${domain_absolutist_it:=absolutist.it}`
    - `ns.${domain_wahoo_li:=wahoo.li}`
    - `ns.${domain_absolutist_it:=absolutist.it}`
    - `dns.${domain_wahoo_li:=wahoo.li}`
    - `dns.${domain_absolutist_it:=absolutist.it}`

---

## Features

### Image Configuration

- **Repository**: `ghcr.io/0xerr0r/blocky`
- **Tag**: `v0.29.0`
- **Image Policy**: Automatically updates to the latest patch version (`vX.Y.Z`) based on the `flux-system:blocky:tag` policy.

### Service Configuration

- **Main Service**:
  - Type: `${dns_svc_type:=LoadBalancer}`
  - ClusterIP: `${blocky_cluster_ip}`
  - External Traffic Policy: `Local`
  - Annotations:
    - `lbipam.cilium.io/ips`: `${dns_ip_addr_1},${dns_ip_addr_2},8.8.8.8,8.8.4.4`
    - `service.cilium.io/global`: `"true"`
    - `service.cilium.io/affinity`: `local`
- **TPI-1 Service**:
  - Type: `ClusterIP`
  - Ports: Derived from `main` service
  - Annotations:
    - `service.cilium.io/global`: `"true"`
    - `service.cilium.io/affinity`: `local`

### DNS Configuration

- **Bootstrap DNS**: `tcp+udp:${unbound_cluster_ip}:${dns_svc_port:=53}`
- **Upstreams**:
  - Default group: `tcp+udp:${unbound_cluster_ip}:${dns_svc_port:=53}`
  - Strategy: `strict`
  - Timeout: `2s`
- **Custom DNS**:
  - Custom TTL: `1h`
  - Mapping:
    - `ns1.absolutist.it`: `${dns_ip_addr_1}`
    - `ns2.absolutist.it`: `${dns_ip_addr_2}`
    - `dns.absolutist.it`: `${dns_ip_addr_1},${dns_ip_addr_2}`
    - `kubedns.absolutist.it`: `${dns_ip_addr_3}`
- **Conditional Mapping**:
  - Default: `${router_ip}`
  - Specific mappings for subdomains and CIDRs.

### Blocking and Filtering

- **Denylists**:
  - Categories: `homeassistant`, `iot`, `not`, `guest`, `ads`
  - Sources include local files and external URLs (e.g., AdGuard, StevenBlack hosts).
- **Allowlists**:
  - Categories: `homeassistant`, `not`, `ads`
  - Includes specific domain patterns and local files.
- **Blocking Behavior**:
  - Default: `zeroIp`
  - Block TTL: `30m`
- **List Refresh**:
  - Refresh Period: `24h`
  - Download Timeout: `60s`
  - Max Download Attempts: `5`

### Caching

- **Min Cache Time**: `5m`
- **Max Cache Time**: `60m`
- **Negative Cache Time**: `30m`
- **Prefetching**:
  - Enabled: `true`
  - Expiry: `2h`
  - Threshold: `5`

### Logging

- **Level**: `info`
- **Format**: `json`
- **Timestamp**: Enabled
- **Privacy Mode**: Disabled

### Prometheus Metrics

- **Enabled**: `true`
- **Path**: `/metrics`

---

## Additional Resources

- **ImageRepository**: `blocky` (source: `ghcr.io/0xerr0r/blocky`)
- **ImagePolicy**: Automatically updates to the latest patch version.
- **ConfigMap**: `blocky-values-bcf8m6kfk4` contains additional configuration values.
- **Certificate**: Managed by `cert-manager` for DNS-over-HTTPS (DoH) and DNS-over-TLS (DoT).

For further details, refer to the [Blocky documentation](https://github.com/0xERR0R/blocky).
