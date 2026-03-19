---
title: "cert-manager-issuers"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# cert-manager-issuers

## Overview
The `cert-manager-issuers` component is responsible for managing certificate issuance within the cluster `nas`. It leverages `cert-manager` to create and manage certificates and issuers, which are used for securing communication and enabling TLS for various services. This component defines multiple `ClusterIssuer` resources for different use cases, including self-signed certificates and Let's Encrypt ACME certificates for both production and staging environments.

## Resource Glossary
This component creates the following Kubernetes resources:

### Security
- **Certificate (`selfsigned-ca-certificate`)**:  
  A self-signed certificate used as a Certificate Authority (CA). This certificate is stored in the `tls-selfsigned-ca` secret in the `cert-manager` namespace. It uses the ECDSA algorithm with a key size of 256 bits.

- **ClusterIssuer (`selfsigned`)**:  
  A `ClusterIssuer` that generates self-signed certificates. This is used for issuing certificates without relying on an external CA.

- **ClusterIssuer (`selfsigned-ca`)**:  
  A `ClusterIssuer` that uses the self-signed CA certificate stored in the `tls-selfsigned-ca` secret to issue certificates.

- **ClusterIssuer (`letsencrypt-production`)**:  
  A `ClusterIssuer` configured to use Let's Encrypt's production ACME server for issuing certificates. It uses DNS-01 challenges with Cloudflare as the DNS provider. The required API token is stored in the `cloudflare-api-token-secret` secret, and the email address for Let's Encrypt notifications is configurable via the `${cloudflare_email}` variable. It supports the following DNS zones:
  - `${domain_absolutist_it}` (default: `absolutist.it`)
  - `${domain_wahoo_li}` (default: `wahoo.li`)

- **ClusterIssuer (`letsencrypt-staging`)**:  
  A `ClusterIssuer` configured to use Let's Encrypt's staging ACME server for testing purposes. It also uses DNS-01 challenges with Cloudflare as the DNS provider. The configuration is similar to the production issuer, with the email address and DNS zones being configurable via the same variables.

- **ClusterIssuer (`clustermesh-issuer`)**:  
  A `ClusterIssuer` that uses a CA certificate stored in the `clustermesh-ca` secret. This is likely used for internal cluster communication or specific services requiring a dedicated CA.

## Configuration Highlights
- **Self-signed CA Certificate**:
  - Algorithm: ECDSA
  - Key size: 256 bits
  - Secret: `tls-selfsigned-ca`

- **Let's Encrypt Issuers**:
  - ACME server URLs:
    - Production: `https://acme-v02.api.letsencrypt.org/directory`
    - Staging: `https://acme-staging-v02.api.letsencrypt.org/directory`
  - DNS-01 solver:
    - Provider: Cloudflare
    - API token secret: `cloudflare-api-token-secret`
    - Configurable email: `${cloudflare_email}`
    - Supported DNS zones:
      - `${domain_absolutist_it}` (default: `absolutist.it`)
      - `${domain_wahoo_li}` (default: `wahoo.li`)

## Deployment
- **Target Namespace**: `cert-manager`
- **Reconciliation**: Managed by Flux with the `infrastructure-platform` Kustomization in the `flux-system` namespace.
- **Configurable Parameters**:
  - `${cloudflare_email}`: Email address for Let's Encrypt notifications.
  - `${domain_absolutist_it}`: Primary DNS zone (default: `absolutist.it`).
  - `${domain_wahoo_li}`: Secondary DNS zone (default: `wahoo.li`).
