---
title: "nas-external-dns"
parent: "Infrastructure / Internal-dns"
grand_parent: "nas"
---

# nas-external-dns

## Overview
The `nas-external-dns` component is responsible for dynamically managing DNS records for Kubernetes resources in the `nas` cluster. It uses the ExternalDNS Helm chart to integrate with an RFC2136-compatible DNS provider (e.g., Bind9) and updates DNS records based on Kubernetes resource changes. This component ensures that services, CRDs, and Gateway routes are discoverable via DNS.

## Dependencies
The `nas-external-dns` HelmRelease depends on the `internal-dns--bind9` HelmRelease. The `internal-dns--bind9` component provides the RFC2136-compatible DNS server (`bind9.internal-dns.svc.cluster.local`) that `nas-external-dns` interacts with to manage DNS records.

## Helm Chart(s)
- **Chart Name:** external-dns  
- **Repository:** [external-dns](https://kubernetes-sigs.github.io/external-dns/)  
- **Version:** 1.15.0  

## Resource Glossary
### Networking
- **Service**:  
  - Name: `nas-external-dns`  
  - Type: `ClusterIP`  
  - Port: `7979` (HTTP)  
  - Provides access to the ExternalDNS health endpoint.

### Workload
- **Deployment**:  
  - Name: `nas-external-dns`  
  - Namespace: `internal-dns`  
  - Replicas: `1`  
  - Container:  
    - Image: `registry.k8s.io/external-dns/external-dns:v0.15.0`  
    - Security Context: Runs as non-root with restricted privileges.  
    - Ports:  
      - `7979` (HTTP) for health checks.  
    - Arguments: Configured to interact with RFC2136 DNS provider, manage DNS records for multiple domain filters, and support various Kubernetes resource types (services, CRDs, Gateway routes).  

### Security
- **ServiceAccount**:  
  - Name: `nas-external-dns`  
  - Namespace: `internal-dns`  
  - Used by the Deployment to interact with the Kubernetes API securely.  

- **ClusterRole**:  
  - Name: `nas-external-dns`  
  - Grants permissions to list, watch, and get Kubernetes resources such as nodes, pods, services, endpoints, namespaces, and Gateway routes.  

- **ClusterRoleBinding**:  
  - Name: `nas-external-dns-viewer`  
  - Binds the `nas-external-dns` ServiceAccount to the `nas-external-dns` ClusterRole for access control.

## Configuration Highlights
- **Log Level**: Set to `error` for minimal logging.  
- **Log Format**: Configured as `json`.  
- **Domain Filters**:  
  - `${domain_wahoo_li:=wahoo.li}`  
  - `${domain_absolutist_it:=absolutist.it}`  
  - `${local_ip_reverse}`  
  - `${tpi_1_ip_reverse}`  
- **Sources**: Monitors services, CRDs, and Gateway routes (`httproute`, `tlsroute`, `tcproute`, `udproute`) for DNS updates.  
- **Provider**: Configured to use `rfc2136` with the following settings:  
  - Host: `bind9.internal-dns.svc.cluster.local`  
  - Port: `53`  
  - Zone: Multiple zones are supported via domain filters.  
  - TSIG Key: `externaldns-key`  
  - TSIG Algorithm: `hmac-sha256`  
  - TSIG Secret: `${local_external_dns_key}`  
  - Additional settings: `--rfc2136-create-ptr` for creating PTR records.  

## Deployment
- **Target Namespace**: `internal-dns`  
- **Release Name**: `nas-external-dns`  
- **Reconciliation Interval**: Every 10 minutes.  
- **Install/Upgrade Behavior**:  
  - Retries: Unlimited (`-1`).  
  - Timeout: 10 minutes.  

This component is configured via multiple ConfigMaps, allowing flexible customization of Helm values. Key parameters such as domain filters and TSIG secrets are defined as Flux variables, enabling dynamic configuration based on the cluster environment.
