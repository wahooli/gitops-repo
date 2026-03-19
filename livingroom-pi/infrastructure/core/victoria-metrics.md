---
title: "victoria-metrics"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# Victoria Metrics

## Overview

The Victoria Metrics component provides monitoring and observability capabilities for the Kubernetes cluster. It is deployed using the `victoria-metrics-operator` Helm chart, which manages the lifecycle of Victoria Metrics resources such as CustomResourceDefinitions (CRDs), deployments, and associated configurations. This operator facilitates the collection, storage, and querying of metrics and logs, making it a critical part of the cluster's monitoring stack.

## Dependencies

The `victoria-metrics-operator` HelmRelease has the following dependencies:
- **cert-manager--cert-manager**: Provides certificate management capabilities required for admission webhooks and other secure communication.
- **prometheus-operator--prometheus-operator-crds**: Ensures the availability of Prometheus-related CRDs, which are essential for integrating Victoria Metrics with Prometheus.

## Helm Chart(s)

### victoria-metrics--victoria-metrics-operator
- **Chart Name**: `victoria-metrics-operator`
- **Repository**: [Victoria Metrics Helm Charts](https://victoriametrics.github.io/helm-charts/)
- **Version**: `0.52.1`

## Resource Glossary

### Namespace
- **victoria-metrics**: Dedicated namespace for all resources related to the Victoria Metrics operator.

### HelmRepository
- **victoria-metrics**: Points to the public Helm chart repository for Victoria Metrics.

### HelmRelease
- **victoria-metrics--victoria-metrics-operator**: Manages the deployment of the Victoria Metrics operator and its associated resources.

### ImageRepository
- **victoria-metrics-operator**: Tracks the container images for the Victoria Metrics operator from the GitHub Container Registry (`ghcr.io/victoriametrics/helm-charts/victoria-metrics-operator`).

### ImagePolicy
- **victoria-metrics-operator**: Defines a semantic versioning policy (`x.x.x`) for automatically updating the Victoria Metrics operator image.

### ConfigMap
- **victoria-metrics-operator-values-59t8mccbt4**: Contains custom Helm values for configuring the Victoria Metrics operator. Key settings include:
  - **admissionWebhooks.enabled**: Enables admission webhooks for validating requests.
  - **admissionWebhooks.certManager.enabled**: Enables certificate creation and injection via cert-manager.
  - **crds.enabled**: Ensures that CustomResourceDefinitions are installed.
  - **crds.cleanup.enabled**: Enables cleanup of CRDs during uninstallation.

### Workload Resources
The HelmRelease deploys the following Kubernetes resources:
- **CustomResourceDefinitions (CRDs)**: 20 CRDs for managing Victoria Metrics-specific resources.
- **ClusterRoles**: Provides cluster-wide permissions for the operator.
- **ClusterRoleBindings**: Binds the ClusterRoles to the operator's ServiceAccount.
- **ServiceAccount**: Used by the operator to interact with the Kubernetes API.
- **Deployment**: Deploys the Victoria Metrics operator.
- **Services**: Exposes the operator for communication within the cluster.
- **ValidatingWebhookConfiguration**: Ensures that incoming requests are validated.
- **Issuer and Certificate**: Manages TLS certificates for secure communication.
- **Role and RoleBinding**: Provides namespace-specific permissions for the operator.

## Configuration Highlights

Key configuration settings for the Victoria Metrics operator:
- **Admission Webhooks**: Enabled to validate incoming requests, ensuring data integrity and security.
- **Cert-Manager Integration**: Certificates are automatically managed and injected using cert-manager.
- **CRD Management**: CRDs are enabled and configured for cleanup during uninstallation.
- **Image Policy**: Ensures the operator image is kept up-to-date with semantic versioning.

## Deployment

- **Target Namespace**: `victoria-metrics`
- **Release Name**: `victoria-metrics-operator`
- **Reconciliation Interval**: Every 10 minutes.
- **Install/Upgrade Behavior**: Unlimited retries are configured for remediation in case of installation or upgrade failures.

This deployment ensures that the Victoria Metrics operator is consistently reconciled and integrates seamlessly with other components in the cluster.
