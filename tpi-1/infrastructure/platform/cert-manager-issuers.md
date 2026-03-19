---
title: "cert-manager-issuers"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# cert-manager-issuers

## Overview

The `cert-manager-issuers` component is responsible for managing certificate issuance in the `tpi-1` cluster. It leverages `cert-manager` to create and manage certificates and issuers, enabling secure communication within the cluster and with external services. This component defines multiple `ClusterIssuer` resources for different use cases, including self-signed certificates, Let's Encrypt production and staging environments, and a custom CA for clustermesh.

## Resource Glossary

### Security

- **ClusterIssuer: `letsencrypt-production`**
  - Provides ACME-based certificate issuance using Let's Encrypt's production environment.
  - Configured with DNS-01 challenge using Cloudflare as the DNS provider.
  - Requires the following configurable parameters:
    - `${cloudflare_email}`: Email address for Let's Encrypt account registration.
    - `${domain_absolutist_it}`: DNS zone for `absolutist.it` (default: `absolutist.it`).
    - `${domain_wahoo_li}`: DNS zone for `wahoo.li` (default: `wahoo.li`).
    - `cloudflare-api-token-secret`: Kubernetes secret containing the Cloudflare API token.

- **ClusterIssuer: `letsencrypt-staging`**
  - Provides ACME-based certificate issuance using Let's Encrypt's staging environment for testing purposes.
  - Configured similarly to `letsencrypt-production` but uses the staging ACME server.

- **ClusterIssuer: `selfsigned`**
  - A simple self-signed issuer for generating certificates without external dependencies.

- **ClusterIssuer: `selfsigned-ca`**
  - A CA-based issuer that uses the self-signed CA certificate stored in the `tls-selfsigned-ca` secret.

- **ClusterIssuer: `clustermesh-issuer`**
  - A CA-based issuer for clustermesh certificates, using the `clustermesh-ca` secret.

- **Certificate: `selfsigned-ca-certificate`**
  - A self-signed CA certificate with the common name `selfsigned-ca`.
  - The certificate is stored in the `tls-selfsigned-ca` secret and is used by the `selfsigned-ca` issuer.

## Configuration Highlights

- **Self-signed CA Certificate**
  - Common Name: `selfsigned-ca`
  - Algorithm: ECDSA
  - Key Size: 256 bits
  - Secret Name: `tls-selfsigned-ca`

- **Let's Encrypt Issuers**
  - ACME Server URLs:
    - Production: `https://acme-v02.api.letsencrypt.org/directory`
    - Staging: `https://acme-staging-v02.api.letsencrypt.org/directory`
  - DNS-01 Challenge:
    - DNS Provider: Cloudflare
    - Configurable Parameters:
      - `${cloudflare_email}`: Email for ACME account.
      - `cloudflare-api-token-secret`: Secret containing the Cloudflare API token.
      - `${domain_absolutist_it}` and `${domain_wahoo_li}`: DNS zones.

- **Clustermesh Issuer**
  - CA Secret Name: `clustermesh-ca`

## Deployment

- **Target Namespace**: `cert-manager`
- **Reconciliation**: Managed by Flux with the `infrastructure-platform` Kustomization in the `flux-system` namespace.
- **Install/Upgrade Behavior**: Resources are reconciled automatically based on the manifests rendered by Flux.

This component does not use Helm charts directly; all resources are defined as Kubernetes manifests managed by Flux.
