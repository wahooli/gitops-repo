---
title: "cert-manager"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# cert-manager

## Overview

The `cert-manager` component is responsible for automating the management and issuance of TLS certificates in the Kubernetes cluster. It integrates with various certificate authorities to request, renew, and manage certificates for workloads and services. This deployment uses the `cert-manager` Helm chart from the Jetstack repository.

## Helm Chart(s)

### cert-manager
- **Chart Name**: `cert-manager`
- **Repository**: [Jetstack](https://charts.jetstack.io)
- **Version**: `v1.17.0`

## Resource Glossary

The `cert-manager` component creates several Kubernetes resources to manage certificates and integrate with the cluster. Below is a summary of the key resources:

### Security
- **ServiceAccounts**: 
  - `cert-manager-cainjector`: Used by the CA injector component to manage CA certificates.
  - `cert-manager`: Used by the main cert-manager controller.
  - `cert-manager-webhook`: Used by the webhook component for validating and mutating admission requests.

- **ClusterRoles and ClusterRoleBindings**: Provide the necessary permissions for the cert-manager components to operate across the cluster.

### Custom Resource Definitions (CRDs)
- **CertificateRequest**, **Certificate**, **Issuer**, and other CRDs: Define the custom resources used by cert-manager to manage certificates and issuers.

### Workloads
- **Deployments**:
  - `cert-manager`: The main controller responsible for managing certificates.
  - `cert-manager-cainjector`: Injects CA certificates into Kubernetes resources.
  - `cert-manager-webhook`: Handles admission webhook requests for validating and mutating cert-manager resources.

### Networking
- **Services**:
  - `cert-manager-webhook`: Exposes the webhook service for admission requests.

- **ValidatingWebhookConfiguration** and **MutatingWebhookConfiguration**: Enable cert-manager to validate and mutate Kubernetes resources during their creation or update.

### Configuration
- **ConfigMap**: 
  - `cert-manager-values-75hbmch4g5`: Contains Helm values used to configure the cert-manager deployment.

- **Secret**:
  - `cloudflare-api-token-secret`: Stores the Cloudflare API token for DNS challenges. The `api-token` value is configurable via the `${cloudflare_api_token}` variable.

## Configuration Highlights

- **Resource Requests and Limits**:
  - **Controller**:
    - Requests: `128Mi` memory, `300m` CPU
    - Limits: `175Mi` memory, `400m` CPU
  - **Webhook**:
    - Requests: `64Mi` memory, `175m` CPU
    - Limits: `175Mi` memory, `500m` CPU
  - **CA Injector**:
    - Requests: `300m` CPU
    - Limits: `175Mi` memory, `800m` CPU

- **Helm Values**:
  - `installCRDs`: `true` (CRDs are installed by the Helm chart).
  - `webhook.timeoutSeconds`: `30` seconds.
  - `prometheus.enabled`: `true` (Prometheus metrics are enabled).
  - `extraArgs`:
    - `--dns01-recursive-nameservers-only`
    - `--dns01-recursive-nameservers=1.1.1.1:53,1.0.0.1:53`
    - `--enable-gateway-api`
    - `--logging-format=json`

- **Tolerations**:
  - Allows scheduling on nodes with the `CriticalAddonsOnly` taint.

## Deployment

- **Target Namespace**: `cert-manager`
- **Release Name**: `cert-manager`
- **Reconciliation Interval**: `10m`
- **Install/Upgrade Behavior**:
  - Unlimited retries on installation failures.
  - Installation timeout: `10m`.

This deployment ensures that cert-manager is configured to handle certificate management efficiently, with appropriate resource allocations and integration with external DNS providers like Cloudflare.
