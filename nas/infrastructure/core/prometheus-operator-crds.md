---
title: "prometheus-operator-crds"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# prometheus-operator-crds

## Overview
The `prometheus-operator-crds` component is responsible for deploying the Custom Resource Definitions (CRDs) required by the Prometheus Operator. These CRDs enable the management of Prometheus monitoring instances and related resources within the Kubernetes cluster. This deployment is crucial for setting up monitoring and alerting capabilities in the cluster.

## Sub-components
This component consists of a single HelmRelease:
- **HelmRelease**: `prometheus-operator--prometheus-operator-crds`
  - **Chart**: `prometheus-operator-crds`
  - **Version**: `30.0.1`
  - **Target Namespace**: `prometheus-operator`
  - **Provides**: Custom Resource Definitions for managing Prometheus and Alertmanager configurations.

## Helm Chart(s)
- **Chart Name**: `prometheus-operator-crds`
- **Repository**: [prometheus-community](https://prometheus-community.github.io/helm-charts)
- **Version**: `30.0.1`

## Resource Glossary
### Custom Resource Definitions (CRDs)
The `prometheus-operator-crds` chart creates the following CRDs:
- **AlertmanagerConfig**: Configures the Prometheus Alertmanager, specifying how alerts should be grouped, inhibited, and notified to external systems. This resource allows users to define rules for alert management, including inhibition rules and mute time intervals.

## Deployment
- **Target Namespace**: `prometheus-operator`
- **Release Name**: `prometheus-operator-crds`
- **Reconciliation Interval**: `10m`
- **Install Behavior**: The installation will retry indefinitely in case of failure, as indicated by `remediation.retries: -1`.
