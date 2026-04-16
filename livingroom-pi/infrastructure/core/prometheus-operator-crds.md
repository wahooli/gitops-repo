---
title: "prometheus-operator-crds"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# prometheus-operator-crds

## Overview
The `prometheus-operator-crds` component is responsible for deploying Custom Resource Definitions (CRDs) that extend the Kubernetes API to support the Prometheus Operator. This operator manages Prometheus monitoring instances and related resources, enabling users to define monitoring configurations declaratively.

## Sub-components
This component consists of a single HelmRelease:
- **HelmRelease**: `prometheus-operator--prometheus-operator-crds`
  - **Chart**: `prometheus-operator-crds`
  - **Version**: `28.0.1`
  - **Target Namespace**: `prometheus-operator`
  - **Provides**: Custom Resource Definitions for managing Prometheus and Alertmanager configurations.

## Helm Chart(s)
- **Chart Name**: `prometheus-operator-crds`
- **Repository**: [prometheus-community](https://prometheus-community.github.io/helm-charts)
- **Version**: `28.0.1`

## Resource Glossary
- **Namespace**: 
  - `prometheus-operator`: A dedicated namespace for resources related to the Prometheus Operator.
  
- **CustomResourceDefinition (CRD)**: 
  - Defines the schema for custom resources used by the Prometheus Operator, including:
    - `AlertmanagerConfig`: Configures the Prometheus Alertmanager, specifying how alerts should be grouped, inhibited, and notified to external systems.

- **HelmRepository**: 
  - `prometheus-community`: A source for Helm charts, specifically for Prometheus-related resources.

- **HelmRelease**: 
  - `prometheus-operator--prometheus-operator-crds`: Manages the installation and updates of the `prometheus-operator-crds` chart.

- **ImageRepository**: 
  - `prometheus-operator-crds`: Defines the source of the container image for the `prometheus-operator-crds`.

- **ImagePolicy**: 
  - `prometheus-operator-crds`: Specifies the policy for managing image versions used in the deployment.

## Configuration Highlights
- **Reconciliation Interval**: The HelmRelease is set to reconcile every 10 minutes.
- **Remediation**: The installation allows for unlimited retries in case of failure.

## Deployment
- **Target Namespace**: `prometheus-operator`
- **Release Name**: `prometheus-operator-crds`
- **Reconciliation Interval**: 10m
- **Install Behavior**: The release will retry indefinitely on failure.
