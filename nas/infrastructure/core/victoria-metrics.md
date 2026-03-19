---
title: "victoria-metrics"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# Victoria Metrics

## Overview

The `victoria-metrics` component deploys the VictoriaMetrics Operator, which is responsible for managing VictoriaMetrics resources within the Kubernetes cluster. VictoriaMetrics is a fast, cost-effective, and scalable monitoring solution and time-series database. The operator simplifies the deployment and management of VictoriaMetrics components, such as monitoring agents and storage backends.

This component is deployed using a single `HelmRelease` resource managed by Flux.

## Dependencies

The `victoria-metrics--victoria-metrics-operator` HelmRelease has the following dependencies:

- **cert-manager--cert-manager**: Provides certificate management capabilities, which are required for the VictoriaMetrics Operator's admission webhooks.
- **prometheus-operator--prometheus-operator-crds**: Ensures that the necessary CustomResourceDefinitions (CRDs) for Prometheus Operator are installed, which are required for monitoring and alerting functionalities.

## Helm Chart(s)

### victoria-metrics--victoria-metrics-operator
- **Chart Name**: `victoria-metrics-operator`
- **Repository**: [VictoriaMetrics Helm Charts](https://victoriametrics.github.io/helm-charts/)
- **Version**: `0.52.1`

## Resource Glossary

The `victoria-metrics` component creates the following Kubernetes resources:

### Core Resources
- **Namespace**: A dedicated namespace named `victoria-metrics` is created to isolate all resources related to the VictoriaMetrics Operator.

### Image Management
- **ImageRepository**: Defines the container image source for the VictoriaMetrics Operator (`ghcr.io/victoriametrics/helm-charts/victoria-metrics-operator`) with an update interval of 24 hours.
- **ImagePolicy**: Specifies a semantic versioning policy (`x.x.x`) to automatically track new versions of the VictoriaMetrics Operator image.

### Helm Management
- **HelmRepository**: Configures the Helm chart repository for VictoriaMetrics at `https://victoriametrics.github.io/helm-charts/` with an update interval of 24 hours.
- **HelmRelease**: Manages the deployment of the VictoriaMetrics Operator using the `victoria-metrics-operator` chart. The release is named `victoria-metrics-operator` and is deployed in the `victoria-metrics` namespace. The reconciliation interval is set to 10 minutes.

### Workload Resources
- **Deployment**: Deploys the VictoriaMetrics Operator as a single Deployment resource in the `victoria-metrics` namespace. This Deployment manages the lifecycle of the operator's pods.
- **ServiceAccount**: A ServiceAccount named `victoria-metrics-operator` is created to provide the necessary permissions for the operator to interact with the Kubernetes API.

### Security and Access Control
- **ClusterRole**: Three ClusterRoles are created to define the permissions required by the VictoriaMetrics Operator.
- **ClusterRoleBinding**: A ClusterRoleBinding is created to bind the ServiceAccount to the appropriate ClusterRoles.
- **Role**: A Role is created to define namespace-specific permissions.
- **RoleBinding**: A RoleBinding is created to bind the ServiceAccount to the Role.

### Networking
- **Service**: A Service is created to expose the VictoriaMetrics Operator within the cluster.
- **ValidatingWebhookConfiguration**: A webhook configuration is created to enable admission control for validating custom resources managed by the operator.

### Certificates
- **Issuer**: Two Issuers are created to manage the certificates required for the operator's webhooks.
- **Certificate**: Two Certificates are created to secure the operator's admission webhooks.

### Custom Resource Definitions (CRDs)
- **CustomResourceDefinition**: 20 CRDs are installed to define the custom resources managed by the VictoriaMetrics Operator. These include resources for managing VictoriaMetrics components like VMCluster, VMAlert, and VMAgent.

### Configuration
- **ConfigMap**: A ConfigMap named `victoria-metrics-operator-values-59t8mccbt4` is used to store Helm values for the VictoriaMetrics Operator. Key settings include:
  - `admissionWebhooks.enabled`: Enables admission webhooks for validating custom resources.
  - `admissionWebhooks.certManager.enabled`: Enables certificate creation and injection by cert-manager.
  - `crds.enabled`: Ensures that CRDs are installed.
  - `crds.cleanup.enabled`: Enables cleanup of CRDs when the HelmRelease is deleted.

## Configuration Highlights

- **Admission Webhooks**: Enabled to validate custom resources.
- **CRDs**: Automatic installation and cleanup of CRDs are enabled.
- **Certificate Management**: Certificates for admission webhooks are managed by cert-manager.

## Deployment

- **Target Namespace**: `victoria-metrics`
- **Release Name**: `victoria-metrics-operator`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: Unlimited retries are configured for remediation in case of installation or upgrade failures.
