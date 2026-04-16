---
title: "prometheus-operator-crds"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# prometheus-operator-crds

## Overview
The `prometheus-operator-crds` component is responsible for deploying Custom Resource Definitions (CRDs) that enable the use of the Prometheus Operator in the Kubernetes cluster. These CRDs define the schema for various monitoring resources, such as Alertmanager configurations, service monitors, and more, allowing users to manage monitoring resources declaratively.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `prometheus-operator--prometheus-operator-crds`
  - **Chart**: `prometheus-operator-crds`
  - **Version**: `28.0.1`
  - **Target Namespace**: `prometheus-operator`
  - **Provides**: Custom Resource Definitions for Prometheus monitoring components.

## Helm Chart(s)
- **Chart Name**: `prometheus-operator-crds`
- **Repository**: `prometheus-community` (https://prometheus-community.github.io/helm-charts)
- **Version**: `28.0.1`

## Resource Glossary
- **Namespace**: 
  - `prometheus-operator`: A dedicated namespace for all resources related to the Prometheus Operator.
  
- **CustomResourceDefinition (CRD)**: 
  - Defines the schema for various monitoring resources. This deployment creates 10 CRDs, including:
    - `alertmanagerconfigs.monitoring.coreos.com`: Configures the Prometheus Alertmanager, specifying how alerts should be grouped, inhibited, and notified to external systems.
    - Other CRDs for service monitors, pod monitors, and alerting rules, enabling users to define and manage monitoring configurations.

- **HelmRepository**: 
  - `prometheus-community`: A reference to the Helm repository where the `prometheus-operator-crds` chart is hosted.

- **HelmRelease**: 
  - `prometheus-operator--prometheus-operator-crds`: Manages the installation and lifecycle of the `prometheus-operator-crds` chart.

- **ImageRepository**: 
  - `prometheus-operator-crds`: Specifies the location of the container image for the Helm chart.

- **ImagePolicy**: 
  - Defines the policy for managing image versions for the `prometheus-operator-crds` image.

## Configuration Highlights
- **Reconciliation Interval**: The HelmRelease is set to reconcile every 10 minutes.
- **Remediation**: The installation allows for unlimited retries in case of failure.

## Deployment
- **Target Namespace**: `prometheus-operator`
- **Release Name**: `prometheus-operator-crds`
- **Reconciliation Interval**: 10m
- **Install/Upgrade Behavior**: The HelmRelease is configured to retry indefinitely on failure.
