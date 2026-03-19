---
title: "tpi-1-external-dns"
parent: "Infrastructure / Internal-dns"
grand_parent: "tpi-1"
---

# tpi-1-external-dns

## Overview
The `tpi-1-external-dns` component manages DNS records for Kubernetes resources in the `tpi-1` cluster. It uses the `external-dns` Helm chart to dynamically update DNS entries based on the state of services, custom resources, and Gateway API routes. This ensures that DNS records are automatically synchronized with the cluster's workloads.

## Dependencies
This component depends on the `internal-dns--bind9` HelmRelease, which provides the RFC2136 DNS server (`bind9`) that `external-dns` interacts with to manage DNS records.

## Helm Chart(s)
- **Chart Name**: external-dns  
- **Repository**: [external-dns](https://kubernetes-sigs.github.io/external-dns/)  
- **Version**: 1.15.0  

## Resource Glossary
### Networking
- **Service**:  
  - Name: `tpi-1-external-dns`  
  - Type: `ClusterIP`  
  - Exposes port `7979` for HTTP-based health checks.  

### Workload
- **Deployment**:  
  - Name: `tpi-1-external-dns`  
  - Replicas: `1`  
  - Runs the `external-dns` container to manage DNS records.  
  - Security context ensures the container runs as non-root with restricted privileges.  

### Security
- **ServiceAccount**:  
  - Name: `tpi-1-external-dns`  
  - Used by the `external-dns` Deployment for RBAC authentication.  

- **ClusterRole**:  
  - Name: `tpi-1-external-dns`  
  - Grants permissions to list/watch Kubernetes resources such as services, endpoints, and Gateway API routes.  

- **ClusterRoleBinding**:  
  - Name: `tpi-1-external-dns-viewer`  
  - Binds the `tpi-1-external-dns` ServiceAccount to the ClusterRole for access control.  

## Configuration Highlights
- **Image**:  
  - Repository: `registry.k8s.io/external-dns/external-dns`  
  - Version: `v0.15.0`  
  - Pull Policy: `IfNotPresent`  

- **DNS Provider**:  
  - Name: `rfc2136`  
  - Host: `bind9.internal-dns.svc.cluster.local`  
  - Port: `53`  
  - Zones:  
    - `${domain_wahoo_li:=wahoo.li}`  
    - `${domain_absolutist_it:=absolutist.it}`  
    - `${local_ip_reverse}`  
    - `${nas_ip_reverse}`  

- **TXT Registry**:  
  - Owner ID: `tpi-1`  
  - Prefix: `internal-dns-`  

- **Logging**:  
  - Level: `error`  
  - Format: `json`  

- **Probes**:  
  - Liveness Probe:  
    - Path: `/healthz`  
    - Port: `7979`  
    - Initial Delay: `10s`  
    - Period: `10s`  
  - Readiness Probe:  
    - Path: `/healthz`  
    - Port: `7979`  
    - Initial Delay: `5s`  
    - Period: `10s`  

## Deployment
- **Target Namespace**: `internal-dns`  
- **Release Name**: `tpi-1-external-dns`  
- **Reconciliation Interval**: `10m`  
- **Install Behavior**:  
  - Retries: Unlimited (`-1`)  
  - Timeout: `10m`  

This component is configured via multiple ConfigMaps, allowing for flexible parameterization of DNS zones, logging, and provider-specific settings. Flux variables (`${variable_name}`) are placeholders for dynamically injected values.
