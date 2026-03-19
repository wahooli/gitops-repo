---
title: "prometheus-operator-crds"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# prometheus-operator-crds

## Overview
The `prometheus-operator-crds` component deploys the Custom Resource Definitions (CRDs) required by the Prometheus Operator. These CRDs enable the creation and management of custom resources such as `AlertmanagerConfig`, `Prometheus`, `ServiceMonitor`, and others, which are essential for configuring and operating Prometheus and Alertmanager within the Kubernetes cluster. This component ensures that the cluster is prepared to support Prometheus Operator functionality.

## Helm Chart(s)
### prometheus-operator-crds
- **Chart Name**: `prometheus-operator-crds`
- **Repository**: `prometheus-community` ([https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts))
- **Version**: `27.0.0`

## Resource Glossary
### Namespace
- **Name**: `prometheus-operator`
- **Purpose**: Provides an isolated Kubernetes namespace for resources related to the Prometheus Operator.

### HelmRepository
- **Name**: `prometheus-community`
- **Purpose**: Defines the Helm chart repository where the `prometheus-operator-crds` chart is sourced from. This repository is updated every 24 hours.

### HelmRelease
- **Name**: `prometheus-operator--prometheus-operator-crds`
- **Purpose**: Manages the deployment of the `prometheus-operator-crds` Helm chart. Ensures the CRDs are installed and reconciled every 10 minutes.

### ImageRepository
- **Name**: `prometheus-operator-crds`
- **Purpose**: Tracks the container image repository for the Prometheus Operator CRDs. Updates are checked every 24 hours.

### ImagePolicy
- **Name**: `prometheus-operator-crds`
- **Purpose**: Defines the policy for selecting container image versions based on semantic versioning (`x.x.x`).

### CustomResourceDefinitions (CRDs)
- **Count**: 10
- **Purpose**: These CRDs enable the creation of custom resources such as `AlertmanagerConfig`, `Prometheus`, `ServiceMonitor`, and others. They are critical for configuring Prometheus and Alertmanager behavior in the cluster.

#### Example CRD: `alertmanagerconfigs.monitoring.coreos.com`
- **Purpose**: Configures the Prometheus Alertmanager, specifying how alerts should be grouped, inhibited, and notified to external systems.
- **Scope**: Namespaced
- **Versions**: `v1alpha1`
- **Key Features**:
  - Define inhibition rules to mute alerts based on specific conditions.
  - Specify mute time intervals to silence notifications during predefined periods.
  - Configure alert grouping and routing.

## Configuration Highlights
- **HelmRelease Settings**:
  - **Reconciliation Interval**: Every 10 minutes.
  - **Install Remediation**: Unlimited retries for installation failures.
- **CRD Details**:
  - Includes definitions for managing Prometheus and Alertmanager configurations, such as alert routing, inhibition rules, and notification settings.

## Deployment
- **Target Namespace**: `prometheus-operator`
- **Release Name**: `prometheus-operator-crds`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: Unlimited retries for installation remediation ensure the CRDs are always deployed successfully.

This component is essential for enabling Prometheus Operator functionality in the cluster by providing the necessary CRDs for resource management and monitoring configuration.
