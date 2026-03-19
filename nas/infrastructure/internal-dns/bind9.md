---
title: "bind9"
parent: "Infrastructure / Internal-dns"
grand_parent: "nas"
---

# bind9

## Overview

The `bind9` component provides a DNS server deployment using the ISC BIND 9 software. It is deployed in the `nas` cluster and serves as an internal DNS solution for managing domain name resolution within the cluster and associated networks. The deployment is managed via Flux and Helm, ensuring automated reconciliation and configuration management.

## Helm Chart(s)

### HelmRelease: `internal-dns--bind9`
- **Chart Name**: `bind9`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)
- **Release Name**: `bind9`
- **Target Namespace**: `internal-dns`
- **Reconciliation Interval**: `5m`

## Resource Glossary

The `bind9` component deploys the following Kubernetes resources:

### Networking
- **Service: `bind9`**
  - Type: LoadBalancer
  - Ports:
    - `53/UDP` (DNS)
    - `53/TCP` (DNS)
    - `443/TCP` (HTTPS)
    - `853/TCP` (DNS over TLS)
  - Annotations:
    - `lbipam.cilium.io/ips`: `${dns_ip_addr_3}`
  - ClusterIP: `${bind9_cluster_ip}`

- **Service: `bind9-nas`**
  - Type: ClusterIP
  - Ports:
    - `53/UDP` (DNS)
    - `53/TCP` (DNS)
    - `443/TCP` (HTTPS)
    - `853/TCP` (DNS over TLS)
  - Annotations:
    - `service.cilium.io/global`: `"true"`
    - `service.cilium.io/affinity`: `"local"`

### Workload
- **Deployment: `bind9`**
  - **Replicas**: 1
  - **Container**:
    - Image: `internetsystemsconsortium/bind9:9.20`
    - Command: `/entrypoint.d/entrypoint-override.sh`
    - Args:
      - `-g`
      - `-4`
      - `-c`
      - `/etc/bind/named.conf`
    - Resource Requests:
      - Memory: `300Mi`
    - Resource Limits:
      - Memory: `512Mi`
    - Liveness Probe:
      - Type: TCP socket
      - Port: `dns-udp`
      - Initial Delay: `2s`
      - Period: `10s`
    - Readiness Probe:
      - Type: TCP socket
      - Port: `dns-udp`

### Configuration
- **ConfigMap: `bind9-entrypoint-override`**
  - Contains a custom entrypoint script (`entrypoint-override.sh`) for initializing and starting the BIND 9 server.
  
- **ConfigMap: `bind9-config-5488hkcg5c`**
  - Stores BIND 9 configuration files, including:
    - `named.conf.keys`: Key definitions for secure DNS updates.
    - `named.conf.logging`: Logging configuration for BIND 9.
    - `named.conf.options`: Global options for the DNS server, including recursion settings, DNSSEC validation, and cache TTL.
    - `named.conf.zones`: Zone definitions for domains such as `absolutist.it`, `wahoo.li`, and reverse lookup zones.

- **ConfigMap: `bind9-zones-dhmb2tdm54`**
  - Contains DNS zone files for domains managed by the BIND 9 server, including:
    - `absolutistit.zone`: Forward lookup zone for `absolutist.it`.
    - `wahooli.zone`: Forward lookup zone for `wahoo.li`.
    - `local.rev.zone`: Reverse lookup zone for local IPs.
    - `tpi-1.rev.zone`: Reverse lookup zone for `tpi-1` IPs.

### Security
- **ServiceAccount: `bind9`**
  - Used by the BIND 9 Deployment for managing permissions within the cluster.

## Configuration Highlights

- **Image**: The deployment uses the `internetsystemsconsortium/bind9:9.20` container image.
- **Resource Requests and Limits**:
  - Requests: `300Mi` memory
  - Limits: `512Mi` memory
- **Persistence**:
  - Configuration files are stored in a `ConfigMap` and mounted to `/etc/bind/named.d`.
  - Zone files are stored in a `ConfigMap` and mounted to `/etc/bind/zones`.
- **Service Annotations**:
  - The `bind9` service uses Cilium annotations for IPAM and external traffic policy.
  - The `bind9-nas` service uses Cilium annotations for global service discovery and local affinity.

## Deployment

- **Target Namespace**: `internal-dns`
- **Release Name**: `bind9`
- **Reconciliation Interval**: `5m`
- **Install/Upgrade Behavior**:
  - Automatic retries on failure (`retries: -1`).
  - Helm values are sourced from two ConfigMaps: `bind9-values-5b48m4k6d6` (`values-base.yaml` and `values.yaml`).

## Notes

- The deployment uses floating version `>=0.1.0-0` for the `bind9` chart, which resolves to the latest available version in the `wahooli` OCI repository.
- Several values in the configuration use Flux variables (e.g., `${dns_ip_addr_3}`, `${dns_svc_type}`, `${local_ip_reverse}`) and should be configured appropriately in the Flux environment.
