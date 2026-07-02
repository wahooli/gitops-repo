---
title: "prometheus-operator-crds"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# prometheus-operator-crds

## Overview
The `prometheus-operator-crds` component is responsible for deploying Custom Resource Definitions (CRDs) that extend the Kubernetes API to support the Prometheus Operator. This operator facilitates the management of Prometheus monitoring instances and their associated configurations, enabling users to define monitoring rules and alerting configurations through Kubernetes-native resources.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `prometheus-operator--prometheus-operator-crds`
  - **Chart**: `prometheus-operator-crds`
  - **Version**: `30.0.1`
  - **Target Namespace**: `prometheus-operator`
  - **Provides**: Custom Resource Definitions for managing Prometheus Alertmanager configurations and other related resources.

## Helm Chart(s)
- **Chart Name**: `prometheus-operator-crds`
- **Repository**: [prometheus-community](https://prometheus-community.github.io/helm-charts)
- **Version**: `30.0.1`

## Resource Glossary
- **Namespace**: 
  - `prometheus-operator`: A dedicated namespace for all resources related to the Prometheus Operator.
  
- **CustomResourceDefinition (CRD)**: 
  - Defines the schema for custom resources used by the Prometheus Operator, including:
    - `alertmanagerconfigs.monitoring.coreos.com`: Configures how alerts are grouped, inhibited, and notified to external systems.

- **ImageRepository**: 
  - `prometheus-operator-crds`: Specifies the image repository for the Prometheus Operator CRDs.

- **ImagePolicy**: 
  - `prometheus-operator-crds`: Defines the policy for managing image versions for the Prometheus Operator CRDs.

- **HelmRepository**: 
  - `prometheus-community`: The source repository for the Helm chart used to deploy the CRDs.

- **HelmRelease**: 
  - `prometheus-operator--prometheus-operator-crds`: Represents the deployment of the CRDs via Helm.

## Configuration Highlights
- **Reconciliation Interval**: The HelmRelease is set to reconcile every 10 minutes.
- **Remediation**: The installation allows for unlimited retries in case of failure.

## Deployment
- **Target Namespace**: `prometheus-operator`
- **Release Name**: `prometheus-operator-crds`
- **Reconciliation Interval**: 10m
- **Install Behavior**: The release will attempt to install indefinitely until successful.
