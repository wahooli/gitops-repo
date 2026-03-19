---
title: "bind9"
parent: "Infrastructure / Internal-dns"
grand_parent: "tpi-1"
---

# Bind9

## Overview
The `bind9` component provides DNS services for the cluster, acting as an authoritative DNS server for internal and external zones. It is deployed using a Helm chart and managed by FluxCD. This component is configured to handle DNS queries, zone transfers, and DNSSEC validation, supporting both IPv4 and IPv6.

## Helm Chart(s)
- **Chart Name**: `bind9`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)

## Resource Glossary
### Networking
- **Service: `bind9`**
  - Type: LoadBalancer
  - Ports:
    - UDP 53 (DNS)
    - TCP 53 (DNS)
    - TCP 443 (HTTPS)
    - TCP 853 (DNS over TLS)
  - ClusterIP: `${bind9_cluster_ip}`
  - External Traffic Policy: Local
  - Annotations:
    - `lbipam.cilium.io/ips`: `${dns_ip_addr_3}`

- **Service: `bind9-tpi-1`**
  - Type: ClusterIP
  - Ports:
    - UDP 53 (DNS)
    - TCP 53 (DNS)
    - TCP 443 (HTTPS)
    - TCP 853 (DNS over TLS)
  - Annotations:
    - `service.cilium.io/global`: `"true"`
    - `service.cilium.io/affinity`: `"local"`

### Workload
- **Deployment: `bind9`**
  - Replicas: 1
  - Image: `ubuntu/bind9:9.20-24.10_edge`
  - Command: `/entrypoint.d/entrypoint-override.sh`
  - Arguments:
    - `-g`
    - `-4`
    - `-c /etc/bind/named.conf`
  - Resource Requests:
    - Memory: 300Mi
  - Resource Limits:
    - Memory: 512Mi
  - Probes:
    - Liveness: TCP socket on port 53 (DNS-UDP)
    - Readiness: TCP socket on port 53 (DNS-UDP)

### Storage
- **ConfigMaps**
  - `bind9-config-579ggdhb5b`: Contains configuration files for `named.conf` (keys, logging, options, zones).
  - `bind9-zones-bb797m7bc5`: Stores DNS zone files (`absolutistit.zone`, `local.rev.zone`, `nas.rev.zone`, `wahooli.zone`).
  - `bind9-values-g759hg4t2b`: Provides Helm values (`values-base.yaml`, `values.yaml`).

### Security
- **ServiceAccount: `bind9`**
  - Used by the `bind9` Deployment to manage permissions.

## Configuration Highlights
- **Persistence**:
  - Config files are mounted at `/etc/bind/named.d`.
  - Zone files are mounted at `/etc/bind/zones`.
  - Both use ConfigMaps (`bind9-config` and `bind9-zones`).
- **DNS Zones**:
  - Internal and external zones are defined in `named.conf.zones` and stored in ConfigMaps.
  - Example zones:
    - `absolutist.it`
    - `wahoo.li`
    - Reverse zones for local and NAS IPs.
- **DNSSEC**:
  - Validation is enabled (`dnssec-validation auto`).
- **Named Configuration**:
  - Custom entrypoint script (`entrypoint-override.sh`) dynamically generates `named.conf` based on mounted configuration files.

## Deployment
- **Target Namespace**: `internal-dns`
- **Release Name**: `bind9`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**:
  - Automatic retries enabled (`retries: -1`).
  - Chart updates checked every 24 hours.
