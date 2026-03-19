---
title: "nas-external-dns"
parent: "Infrastructure / Internal-dns"
grand_parent: "tpi-1"
---

# nas-external-dns

## Overview

The `nas-external-dns` component is responsible for dynamically managing DNS records for Kubernetes resources in the `tpi-1` cluster. It uses the [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) Helm chart to automatically create, update, and delete DNS records based on the state of Kubernetes resources such as Services, Ingresses, and Gateway API resources. This deployment is configured to use the RFC2136 DNS provider to interact with a DNS server.

## Helm Chart(s)

### HelmRelease: `internal-dns--nas-external-dns`
- **Chart Name**: `external-dns`
- **Repository**: [ExternalDNS](https://kubernetes-sigs.github.io/external-dns/)
- **Version**: `1.15.0`
- **Release Name**: `nas-external-dns`
- **Target Namespace**: `internal-dns`
- **Reconciliation Interval**: 10 minutes

## Resource Glossary

### Networking
- **Service**: 
  - Name: `nas-external-dns`
  - Type: `ClusterIP`
  - Exposes the HTTP health endpoint on port `7979` for liveness and readiness probes.

### Workload
- **Deployment**: 
  - Name: `nas-external-dns`
  - Replicas: `1`
  - Runs the `external-dns` container with the image `registry.k8s.io/external-dns/external-dns:v0.15.0`.
  - Configured with strict security contexts, including running as a non-root user and using a read-only filesystem.
  - Probes:
    - Liveness Probe: Checks `/healthz` on port `7979` every 10 seconds.
    - Readiness Probe: Checks `/healthz` on port `7979` every 5 seconds.

### Security
- **ServiceAccount**: 
  - Name: `nas-external-dns`
  - Used by the `external-dns` Deployment for Kubernetes API access.
- **ClusterRole**: 
  - Name: `nas-external-dns`
  - Grants permissions to list and watch Kubernetes resources such as Services, Endpoints, and Gateway API resources.
- **ClusterRoleBinding**: 
  - Name: `nas-external-dns-viewer`
  - Binds the `nas-external-dns` ServiceAccount to the `nas-external-dns` ClusterRole.

### Configuration
- **ConfigMap**: 
  - Name: `nas-external-dns-values-d2bg94b6f9`
  - Contains Helm values for configuring the ExternalDNS deployment, including:
    - **Log Level**: `error`
    - **Log Format**: `json`
    - **Domain Filters**: Filters for specific domains, including `${domain_wahoo_li:=wahoo.li}`, `${domain_absolutist_it:=absolutist.it}`, `${local_ip_reverse}`, and `${nas_ip_reverse}`.
    - **Sources**: Includes `service`, `crd`, and Gateway API resources (`gateway-httproute`, `gateway-tlsroute`, `gateway-tcproute`, `gateway-udproute`).
    - **Provider**: `rfc2136`
    - **TXT Record Settings**:
      - Owner ID: `tpi-1`
      - Prefix: `internal-dns-`
    - **RFC2136 Provider Settings**:
      - Host: `bind9-nas.internal-dns.svc.cluster.local`
      - Port: `53`
      - Zones: `${domain_wahoo_li:=wahoo.li}`, `${domain_absolutist_it:=absolutist.it}`, `${local_ip_reverse}`, `${nas_ip_reverse}`
      - TSIG Key: `externaldns-key`
      - TSIG Algorithm: `hmac-sha256`
      - TSIG Secret: `${nas_external_dns_key}`
      - Create PTR records: Enabled

## Configuration Highlights

- **Image**: `registry.k8s.io/external-dns/external-dns:v0.15.0` with `IfNotPresent` pull policy.
- **Log Level**: Set to `error` for minimal logging.
- **Domain Filters**: Configurable via Flux variables for specific domains and reverse IP zones.
- **RFC2136 Provider**: Configured to interact with a DNS server using TSIG authentication and supports dynamic DNS updates.
- **Probes**: Liveness and readiness probes ensure the health of the deployment.
- **Security Context**: Strictly enforced to enhance security.

## Deployment

- **Target Namespace**: `internal-dns`
- **Release Name**: `nas-external-dns`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: 
  - Unlimited retries for installation remediation.
  - Installation timeout: 10 minutes.

This deployment ensures that DNS records are dynamically managed for Kubernetes resources in the `tpi-1` cluster, leveraging the RFC2136 DNS provider for integration with a Bind9 DNS server. Configuration is highly customizable via Flux variables and ConfigMaps.
