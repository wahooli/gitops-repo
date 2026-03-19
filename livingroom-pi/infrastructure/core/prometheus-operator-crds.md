---
title: "prometheus-operator-crds"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# prometheus-operator-crds

## Overview
The `prometheus-operator-crds` component is responsible for deploying the CustomResourceDefinitions (CRDs) required by the Prometheus Operator. These CRDs define the custom resources used by the Prometheus Operator to manage Prometheus instances, Alertmanager instances, and related configurations within the Kubernetes cluster. This component ensures that the necessary CRDs are available in the cluster for the Prometheus Operator to function correctly.

## Helm Chart(s)
### prometheus-operator-crds
- **Chart Name**: `prometheus-operator-crds`
- **Repository**: [prometheus-community](https://prometheus-community.github.io/helm-charts)
- **Version**: `27.0.0`

## Resource Glossary
The following Kubernetes resources are created by this component:

### CustomResourceDefinitions (CRDs)
The Helm chart deploys the following CRDs, which are essential for the Prometheus Operator to manage monitoring resources:
- **AlertmanagerConfig**: Defines configurations for Prometheus Alertmanager, including alert grouping, inhibition rules, and notification settings.
- **Other CRDs**: The chart deploys a total of 10 CRDs, including those for managing Prometheus instances, Alertmanager instances, and ServiceMonitors. These CRDs enable the Prometheus Operator to monitor and manage workloads effectively.

### Namespace
- **Name**: `prometheus-operator`
- **Purpose**: Provides an isolated namespace for the Prometheus Operator and its associated resources.

### HelmRepository
- **Name**: `prometheus-community`
- **Namespace**: `flux-system`
- **Purpose**: Defines the Helm chart repository from which the `prometheus-operator-crds` chart is sourced.

### ImageRepository
- **Name**: `prometheus-operator-crds`
- **Namespace**: `flux-system`
- **Purpose**: Tracks the container images associated with the `prometheus-operator-crds` chart.

### ImagePolicy
- **Name**: `prometheus-operator-crds`
- **Namespace**: `flux-system`
- **Purpose**: Defines a semantic versioning policy (`x.x.x`) for the container images tracked by the `ImageRepository`.

### HelmRelease
- **Name**: `prometheus-operator--prometheus-operator-crds`
- **Namespace**: `flux-system`
- **Purpose**: Manages the deployment of the `prometheus-operator-crds` Helm chart, ensuring the CRDs are installed and reconciled.

## Configuration Highlights
- **Helm Chart Version**: The `prometheus-operator-crds` chart is pinned to version `27.0.0`, ensuring a consistent deployment.
- **Reconciliation Interval**: The HelmRelease is reconciled every 10 minutes, ensuring that the deployed resources remain in the desired state.
- **Install Behavior**: The HelmRelease is configured with unlimited retries (`retries: -1`) for installation remediation, ensuring that the CRDs are deployed even in the face of transient issues.

## Deployment
- **Target Namespace**: `prometheus-operator`
- **Release Name**: `prometheus-operator-crds`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: The HelmRelease is configured to retry installation indefinitely in case of failures, ensuring high reliability for deploying the CRDs.

This component is critical for enabling the Prometheus Operator to function by providing the necessary CRDs for managing monitoring resources in the cluster.
