---
title: "victoria-metrics"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# Victoria Metrics

## Overview

The `victoria-metrics` component is responsible for deploying and managing the VictoriaMetrics Operator in the `tpi-1` Kubernetes cluster. The VictoriaMetrics Operator is a monitoring solution designed to manage VictoriaMetrics resources, such as monitoring instances and agents, within a Kubernetes environment. It provides features like custom resource definitions (CRDs), admission webhooks, and integration with Cert-Manager for certificate management.

This component is deployed using a single HelmRelease.

## Dependencies

The `victoria-metrics--victoria-metrics-operator` HelmRelease has the following dependencies:

- **cert-manager--cert-manager**: Provides certificate management capabilities, which are required for the admission webhooks in the VictoriaMetrics Operator.
- **prometheus-operator--prometheus-operator-crds**: Supplies the necessary Custom Resource Definitions (CRDs) for Prometheus Operator, which may be used by the VictoriaMetrics Operator.

## Helm Chart(s)

### victoria-metrics--victoria-metrics-operator
- **Chart Name**: `victoria-metrics-operator`
- **Repository**: `victoria-metrics` (https://victoriametrics.github.io/helm-charts/)
- **Version**: `0.52.1`

## Resource Glossary

The following Kubernetes resources are created by this component:

### Core Resources
- **Namespace**: `victoria-metrics`  
  The namespace where all resources related to the VictoriaMetrics Operator are deployed.

### Workload Resources
- **Deployment**:  
  Deploys the VictoriaMetrics Operator, which manages VictoriaMetrics resources in the cluster.

### Security and Access Control
- **ServiceAccount**: `victoria-metrics-operator`  
  Used by the VictoriaMetrics Operator for authentication and authorization within the cluster.
- **ClusterRole**:  
  Defines the permissions required by the VictoriaMetrics Operator to manage cluster-wide resources.
- **ClusterRoleBinding**:  
  Binds the ClusterRole to the ServiceAccount, granting it the necessary permissions.
- **Role** and **RoleBinding**:  
  Provide namespace-specific permissions for the VictoriaMetrics Operator.

### Networking
- **Service**:  
  Exposes the VictoriaMetrics Operator's webhook service for admission control.

### Custom Resource Definitions (CRDs)
- **CustomResourceDefinition**:  
  Defines 20 custom resources for managing VictoriaMetrics components, such as monitoring instances and agents.

### Certificates
- **Issuer** and **Certificate**:  
  Used for generating and managing TLS certificates for the admission webhooks. These resources are managed by Cert-Manager.

### Webhooks
- **ValidatingWebhookConfiguration**:  
  Configures admission webhooks for validating custom resources managed by the VictoriaMetrics Operator.

### Image Automation
- **ImageRepository**:  
  Tracks the container image for the VictoriaMetrics Operator (`ghcr.io/victoriametrics/helm-charts/victoria-metrics-operator`) and checks for updates every 24 hours.
- **ImagePolicy**:  
  Defines a semantic versioning policy (`x.x.x`) for automatically selecting new versions of the VictoriaMetrics Operator image.

### Configuration
- **ConfigMap**: `victoria-metrics-operator-values-59t8mccbt4`  
  Contains custom Helm values for configuring the VictoriaMetrics Operator. Key settings include:
  - **admissionWebhooks.enabled**: Enables admission webhooks for validating custom resources.
  - **admissionWebhooks.certManager.enabled**: Uses Cert-Manager for certificate creation and injection.
  - **crds.enabled**: Ensures that CRDs are installed.
  - **crds.cleanup.enabled**: Enables cleanup of CRDs when the HelmRelease is deleted.

## Configuration Highlights

- **Admission Webhooks**: Enabled with Cert-Manager integration for automatic certificate management.
- **CRD Management**: CRDs are installed and cleaned up automatically.
- **Image Automation**: The VictoriaMetrics Operator image is tracked and updated based on semantic versioning (`x.x.x`).

## Deployment

- **Target Namespace**: `victoria-metrics`
- **Release Name**: `victoria-metrics-operator`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: Unlimited retries are configured for remediation in case of installation or upgrade failures.

This component is managed by Flux and uses a HelmRelease to ensure the VictoriaMetrics Operator is deployed and reconciled with the desired state. Configuration values are sourced from a ConfigMap, allowing for easy customization and updates.
