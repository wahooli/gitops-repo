---
title: "knative-operator"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# knative-operator

## Overview
The `knative-operator` component is responsible for managing the lifecycle of Knative Serving resources in the Kubernetes cluster. It automates the deployment and configuration of Knative components, enabling serverless capabilities on Kubernetes.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `knative-serving--knative-operator`
  - **Chart**: `knative-operator`
  - **Version**: `v1.21.1`
  - **Target Namespace**: `knative-serving`
  - **Provides**: Management of Knative Serving resources, including deployments, configurations, and observability settings.

## Dependencies
There are no dependencies specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `knative-operator`
- **Repository**: [knative-operator](https://knative.github.io/operator)
- **Version**: `v1.21.1`

## Resource Glossary
### Security
- **ServiceAccount**: Two service accounts are created (`knative-operator` and `operator-webhook`) in the `knative-serving` namespace to manage permissions for the operator and its webhook.

### Configuration
- **ConfigMap**: 
  - `config-logging`: Contains configuration for logging, including log levels and output formats.
  - `config-observability`: Contains settings for observability, such as metrics backend destinations and logging URL templates.

### Networking
- **Secret**: `operator-webhook-certs` is created to store certificates for the operator's webhook.

### Roles and Bindings
- **ClusterRoleBinding** and **ClusterRole**: These resources define permissions for the operator to manage Knative resources across the cluster.

### Workload
- **Deployment**: Two deployments are created to run the operator and its webhook, ensuring high availability and scalability.

## Configuration Highlights
- The operator is configured to create and replace Custom Resource Definitions (CRDs) during installation and upgrades.
- The reconciliation interval for the HelmRelease is set to 10 minutes, ensuring that the state of the deployment is regularly checked and updated.
- Configurations for logging and observability are provided through ConfigMaps, allowing customization of logging levels and metrics destinations.

## Deployment
- **Target Namespace**: `knative-serving`
- **Release Name**: `knative-operator`
- **Reconciliation Interval**: 10 minutes
- **Install Behavior**: CRDs are created or replaced as needed.
- **Upgrade Behavior**: CRDs are also created or replaced during upgrades.
