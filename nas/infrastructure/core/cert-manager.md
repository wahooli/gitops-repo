---
title: "cert-manager"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# cert-manager

## Overview

The `cert-manager` component is a Kubernetes add-on that automates the management and issuance of TLS certificates. It integrates with various certificate authorities (CAs) to issue certificates for your Kubernetes workloads, ensuring secure communication. This deployment is managed using Flux and Helm, and it is configured to install the necessary Custom Resource Definitions (CRDs) for its operation.

## Helm Chart(s)

### cert-manager--cert-manager
- **Chart Name**: `cert-manager`
- **Repository**: `jetstack` ([https://charts.jetstack.io](https://charts.jetstack.io))
- **Version**: `v1.17.0`

## Resource Glossary

The `cert-manager` component creates the following key Kubernetes resources:

### Security
- **ServiceAccounts**:
  - `cert-manager`: Used by the cert-manager controller for managing certificates.
  - `cert-manager-cainjector`: Used by the CA injector to inject CA data into Kubernetes resources.
  - `cert-manager-webhook`: Used by the webhook component to validate and mutate resources.

- **ClusterRoles and ClusterRoleBindings**:
  - 13 `ClusterRole` resources and 10 `ClusterRoleBinding` resources are created to define and bind permissions for the cert-manager components.

- **Role and RoleBindings**:
  - 4 `Role` and 4 `RoleBinding` resources are created to manage namespace-specific permissions.

### Custom Resource Definitions (CRDs)
- 6 `CustomResourceDefinition` resources are created to define the custom resources used by cert-manager, such as `Certificate`, `Issuer`, and `CertificateRequest`.

### Workloads
- **Deployments**:
  - `cert-manager`: The main controller responsible for managing certificates.
  - `cert-manager-cainjector`: Injects CA certificates into Kubernetes resources.
  - `cert-manager-webhook`: Provides validation and mutation for cert-manager resources.

### Networking
- **Services**:
  - 3 `Service` resources are created to expose the `cert-manager`, `cainjector`, and `webhook` components.

- **Webhook Configurations**:
  - 1 `ValidatingWebhookConfiguration` and 1 `MutatingWebhookConfiguration` are created to handle resource validation and mutation.

### Configuration
- **ConfigMap**:
  - `cert-manager-values-75hbmch4g5`: Stores Helm values for configuring the cert-manager deployment.

- **Secret**:
  - `cloudflare-api-token-secret`: Contains the Cloudflare API token for DNS-01 challenge support. The token value is configurable via the `${cloudflare_api_token}` parameter.

### Namespace
- **Namespace**:
  - `cert-manager`: The namespace where all cert-manager resources are deployed.

## Configuration Highlights

- **Resource Requests and Limits**:
  - `cert-manager`:
    - Requests: 300m CPU, 128Mi memory
    - Limits: 400m CPU, 175Mi memory
  - `cainjector`:
    - Requests: 300m CPU
    - Limits: 800m CPU, 175Mi memory
  - `webhook`:
    - Requests: 175m CPU, 64Mi memory
    - Limits: 500m CPU, 175Mi memory

- **Helm Values**:
  - `installCRDs`: Enabled (`true`) to ensure CRDs are installed automatically.
  - `webhook.timeoutSeconds`: Set to 30 seconds.
  - `prometheus.enabled`: Enabled to expose metrics for monitoring.
  - `extraArgs`:
    - `--dns01-recursive-nameservers-only`
    - `--dns01-recursive-nameservers=1.1.1.1:53,1.0.0.1:53`
    - `--enable-gateway-api`
    - `--logging-format=json`

- **Webhook Configuration**:
  - Additional arguments for logging in JSON format are provided for the webhook and cainjector components.

- **Tolerations**:
  - Configured to tolerate `CriticalAddonsOnly` taints for scheduling on critical nodes.

## Deployment

- **Target Namespace**: `cert-manager`
- **Release Name**: `cert-manager`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**:
  - Unlimited retries (`retries: -1`) for remediation during installation.
  - Installation timeout set to 10 minutes.

This deployment uses Flux to manage the HelmRelease and ensures that the cert-manager is consistently reconciled with the desired state. Configuration values are sourced from a ConfigMap, allowing for flexible and centralized management of settings.
