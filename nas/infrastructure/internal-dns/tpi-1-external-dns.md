---
title: "tpi-1-external-dns"
parent: "Infrastructure / Internal-dns"
grand_parent: "nas"
---

# tpi-1-external-dns

## Overview

The `tpi-1-external-dns` component is responsible for dynamically managing DNS records for Kubernetes resources in the `nas` cluster. It uses the `external-dns` Helm chart to automatically create, update, and delete DNS records based on the state of Kubernetes resources such as Services, CRDs, and Gateway API routes. This deployment is configured to use the RFC2136 DNS provider for integration with a DNS server.

## Helm Chart(s)

- **Chart Name**: `external-dns`
- **Repository**: [external-dns](https://kubernetes-sigs.github.io/external-dns/)
- **Version**: `1.15.0`

## Resource Glossary

This component creates the following Kubernetes resources:

### Networking
- **Service**: Exposes the `external-dns` Deployment within the `internal-dns` namespace as a `ClusterIP` service on port `7979`. This service is used for health checks.

### Workload
- **Deployment**: Runs the `external-dns` application as a single replica. The container uses the `registry.k8s.io/external-dns/external-dns:v0.15.0` image and is configured with strict security settings, including running as a non-root user and using a read-only filesystem.

### Security
- **ServiceAccount**: A dedicated ServiceAccount named `tpi-1-external-dns` in the `internal-dns` namespace, used by the `external-dns` Deployment.
- **ClusterRole**: Grants permissions to the `tpi-1-external-dns` ServiceAccount to list and watch Kubernetes resources such as Services, Endpoints, CRDs, and Gateway API routes.
- **ClusterRoleBinding**: Binds the `tpi-1-external-dns` ClusterRole to the `tpi-1-external-dns` ServiceAccount.

## Configuration Highlights

Key configuration settings for this deployment include:

- **Image**: `registry.k8s.io/external-dns/external-dns:v0.15.0`
- **Log Level**: `error`
- **Log Format**: `json`
- **Sources**: The following Kubernetes resources are monitored for DNS record management:
  - `service`
  - `crd`
  - `gateway-httproute`
  - `gateway-tlsroute`
  - `gateway-tcproute`
  - `gateway-udproute`
- **Provider**: RFC2136 DNS provider with the following settings:
  - `rfc2136-host`: `bind9-tpi-1.internal-dns.svc.cluster.local.`
  - `rfc2136-port`: `53`
  - `rfc2136-tsig-secret-alg`: `hmac-sha256`
  - `rfc2136-tsig-keyname`: `externaldns-key`
  - `rfc2136-tsig-secret`: `${tpi_1_external_dns_key}` (configurable via Flux variable)
  - `rfc2136-create-ptr`: Enabled
- **Domain Filters**: Limits DNS management to the following domains:
  - `${domain_wahoo_li:=wahoo.li}`
  - `${domain_absolutist_it:=absolutist.it}`
  - `${local_ip_reverse}`
  - `${tpi_1_ip_reverse}`
- **TXT Registry**:
  - `txtOwnerId`: `nas`
  - `txtPrefix`: `internal-dns-`
- **Tolerations**: Configured to allow scheduling on nodes with the `CriticalAddonsOnly` taint.

## Deployment

- **Target Namespace**: `internal-dns`
- **Release Name**: `tpi-1-external-dns`
- **Reconciliation Interval**: Every 10 minutes
- **Install Behavior**: Retries indefinitely on failure, with a timeout of 10 minutes per attempt.

This deployment is managed by Flux and uses a combination of ConfigMaps to provide custom Helm values. The `serviceMonitor` feature is disabled by default and can be enabled manually after Prometheus is installed.
