---
title: "cert-manager-issuers"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# cert-manager-issuers

## Overview

The `cert-manager-issuers` component is responsible for managing certificate issuance within the `livingroom-pi` cluster. It leverages `cert-manager` to define and manage ClusterIssuers and Certificates, which are used to issue and manage TLS certificates for various workloads. This component ensures secure communication within the cluster by providing self-signed and CA-based certificates.

## Resource Glossary

### Security

1. **Certificate: `selfsigned-ca-certificate`**
   - **Namespace:** `cert-manager`
   - **Description:** This resource defines a self-signed Certificate named `selfsigned-ca-certificate`. It acts as a Certificate Authority (CA) for issuing other certificates. The certificate is stored in the `tls-selfsigned-ca` secret and uses ECDSA with a key size of 256 bits.

2. **ClusterIssuer: `selfsigned`**
   - **Description:** A `ClusterIssuer` that uses a self-signed strategy to issue certificates. This is used as the issuer for the `selfsigned-ca-certificate`.

3. **ClusterIssuer: `selfsigned-ca`**
   - **Description:** A `ClusterIssuer` that references the `tls-selfsigned-ca` secret created by the `selfsigned-ca-certificate`. This issuer can be used to issue certificates signed by the self-signed CA.

4. **ClusterIssuer: `clustermesh-issuer`**
   - **Namespace:** `cert-manager`
   - **Description:** A `ClusterIssuer` that uses the `clustermesh-ca` secret as its CA. This issuer is intended for issuing certificates for the cluster mesh.

## Deployment

- **Target Namespace:** `cert-manager`
- **Reconciliation Interval:** Managed by Flux, reconciliation occurs automatically based on the Flux configuration.
- **Install/Upgrade Behavior:** The resources are applied and managed declaratively by Flux. Updates to the manifests will trigger reconciliation and apply changes to the cluster.

This component is essential for managing TLS certificates in the `livingroom-pi` cluster, ensuring secure communication between services and components. Configuration and behavior are fully managed through the Flux GitOps workflow.
