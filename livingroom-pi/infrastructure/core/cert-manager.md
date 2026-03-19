---
title: "cert-manager"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# cert-manager

## Overview

`cert-manager` is a Kubernetes add-on that automates the management and issuance of TLS certificates. It simplifies the process of obtaining, renewing, and using certificates from various certificate authorities (CAs) to secure your Kubernetes workloads. In this deployment, `cert-manager` is used to manage certificates for the `livingroom-pi` cluster.

## Helm Chart(s)

### cert-manager
- **Chart Name**: `cert-manager`
- **Repository**: [jetstack](https://charts.jetstack.io)
- **Version**: `v1.17.0`

## Resource Glossary

The `cert-manager` component creates the following Kubernetes resources:

### Namespace
- **`cert-manager`**: A dedicated namespace for all `cert-manager` resources.

### HelmRepository
- **`jetstack`**: A Helm repository pointing to `https://charts.jetstack.io`, which hosts the `cert-manager` Helm chart.

### HelmRelease
- **`cert-manager--cert-manager`**: A Flux HelmRelease resource that manages the deployment of the `cert-manager` Helm chart in the `cert-manager` namespace.

### ConfigMap
- **`cert-manager-values-2t88kbg8d9`**: A ConfigMap containing the Helm values for configuring the `cert-manager` deployment. It includes base values, additional values, and optional extra values.

### Secret
- **`cloudflare-api-token-secret`**: A Kubernetes Secret in the `cert-manager` namespace that stores the Cloudflare API token (`${cloudflare_api_token}`) for DNS challenges.

### Workload Resources
The following resources are created by the `cert-manager` Helm chart:

#### Security
- **ServiceAccounts**:
  - `cert-manager`: Used by the main cert-manager controller.
  - `cert-manager-cainjector`: Used by the CA injector component.
  - `cert-manager-webhook`: Used by the webhook component.

- **ClusterRoles and ClusterRoleBindings**: Provide the necessary permissions for the cert-manager components to interact with the Kubernetes API.

- **Roles and RoleBindings**: Provide namespace-scoped permissions for cert-manager components.

#### Custom Resource Definitions (CRDs)
- **6 CRDs**: Define the custom resources used by cert-manager, such as `Certificate`, `Issuer`, and `CertificateRequest`.

#### Deployments
- **`cert-manager`**: The main controller responsible for managing certificates.
- **`cert-manager-cainjector`**: Injects CA certificates into Kubernetes resources.
- **`cert-manager-webhook`**: Handles validation and mutation of cert-manager resources.

#### Networking
- **Services**:
  - `cert-manager`: Exposes the main cert-manager controller.
  - `cert-manager-webhook`: Exposes the webhook component.
  - `cert-manager-cainjector`: Exposes the CA injector component.

- **Webhook Configurations**:
  - **ValidatingWebhookConfiguration**: Ensures that cert-manager resources are valid before being persisted.
  - **MutatingWebhookConfiguration**: Automatically modifies cert-manager resources to ensure they are correctly configured.

## Configuration Highlights

- **Resource Requests and Limits**:
  - **Controller**:
    - Requests: 128Mi memory, 300m CPU
    - Limits: 175Mi memory, 400m CPU
  - **Webhook**:
    - Requests: 64Mi memory, 175m CPU
    - Limits: 175Mi memory, 500m CPU
  - **CA Injector**:
    - Requests: 300m CPU
    - Limits: 175Mi memory, 800m CPU

- **Custom Resource Definitions (CRDs)**:
  - CRDs are installed automatically (`installCRDs: true`).

- **Webhook Configuration**:
  - Webhook timeout is set to 30 seconds.
  - Webhook resources are configured with specific CPU and memory requests/limits.

- **DNS01 Challenge**:
  - Configured to use recursive nameservers `1.1.1.1:53` and `1.0.0.1:53` for DNS-01 challenges.

- **Prometheus Metrics**:
  - Prometheus metrics are enabled (`prometheus.enabled: true`).

- **Tolerations**:
  - Tolerations are configured to allow scheduling on nodes with the `CriticalAddonsOnly` taint.

## Deployment

- **Target Namespace**: `cert-manager`
- **Release Name**: `cert-manager`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**:
  - Automatic retries are enabled (`retries: -1`).
  - Installation timeout is set to 10 minutes.

This deployment uses Flux to manage the lifecycle of the `cert-manager` HelmRelease. The HelmRelease is configured to pull the `cert-manager` chart from the Jetstack Helm repository and apply custom values from the `cert-manager-values-2t88kbg8d9` ConfigMap.
