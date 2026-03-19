---
title: "prometheus-operator-crds"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# prometheus-operator-crds

## Overview
The `prometheus-operator-crds` component is responsible for deploying the CustomResourceDefinitions (CRDs) required by the Prometheus Operator. These CRDs define the custom resources used to configure and manage Prometheus, Alertmanager, and related components within the Kubernetes cluster. This component ensures that the necessary CRDs are available for the Prometheus Operator to function correctly.

## Helm Chart(s)
- **Chart Name:** `prometheus-operator-crds`
- **Repository:** [prometheus-community](https://prometheus-community.github.io/helm-charts)
- **Version:** 27.0.0

## Resource Glossary
This component creates the following Kubernetes resources:

### CustomResourceDefinitions (CRDs)
The `prometheus-operator-crds` Helm chart deploys the following CRDs, which are essential for the Prometheus Operator:

1. **AlertmanagerConfig (alertmanagerconfigs.monitoring.coreos.com):**
   - Defines configurations for the Prometheus Alertmanager, including alert grouping, inhibition rules, and notification settings.
   - Allows users to specify how alerts are grouped, silenced, and routed to external systems.

2. **Other CRDs:**
   - The chart deploys a total of 10 CRDs, which include definitions for managing Prometheus instances, Alertmanager instances, and other related resources. These CRDs enable the Prometheus Operator to manage monitoring and alerting configurations in a Kubernetes-native way.

### Namespace
- **Name:** `prometheus-operator`
- **Purpose:** Provides an isolated namespace for the Prometheus Operator and its associated resources.

### HelmRepository
- **Name:** `prometheus-community`
- **Namespace:** `flux-system`
- **Purpose:** Defines the Helm chart repository from which the `prometheus-operator-crds` chart is sourced.

### ImageRepository
- **Name:** `prometheus-operator-crds`
- **Namespace:** `flux-system`
- **Purpose:** Tracks the container image for the `prometheus-operator-crds` chart in the GitOps workflow.

### ImagePolicy
- **Name:** `prometheus-operator-crds`
- **Namespace:** `flux-system`
- **Purpose:** Defines the image update policy for the `prometheus-operator-crds` chart, using semantic versioning (`x.x.x`).

### HelmRelease
- **Name:** `prometheus-operator--prometheus-operator-crds`
- **Namespace:** `flux-system`
- **Purpose:** Manages the deployment of the `prometheus-operator-crds` Helm chart in the `prometheus-operator` namespace.

## Configuration Highlights
- **Chart Version:** 27.0.0
- **Reconciliation Interval:** 10 minutes
- **Install Remediation:** Unlimited retries for installation in case of failure.
- **Target Namespace:** `prometheus-operator`

## Deployment
- **Target Namespace:** `prometheus-operator`
- **Release Name:** `prometheus-operator-crds`
- **Reconciliation Interval:** 10 minutes
- **Install/Upgrade Behavior:** The HelmRelease is configured to retry installation indefinitely in case of failure, ensuring the CRDs are deployed successfully.

This component is managed by Flux and is part of the `infrastructure-core` Kustomization in the `flux-system` namespace. It is critical for enabling the Prometheus Operator to manage monitoring and alerting resources in the cluster.
