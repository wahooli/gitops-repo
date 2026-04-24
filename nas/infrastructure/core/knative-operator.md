---
title: "knative-operator"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# knative-operator

## Overview
The `knative-operator` component is responsible for managing the lifecycle of Knative Serving resources in the Kubernetes cluster. It simplifies the deployment and management of Knative components, ensuring that they are correctly configured and operational.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `knative-serving--knative-operator`
  - **Chart**: `knative-operator`
  - **Version**: `v1.21.1`
  - **Target Namespace**: `knative-serving`
  - **Provides**: Manages Knative Serving resources, including deployments, services, and configuration for observability and logging.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `knative-operator`
- **Repository**: [knative-operator](https://knative.github.io/operator)
- **Version**: `v1.21.1`

## Resource Glossary
### Security
- **ServiceAccount**: Two service accounts (`knative-operator` and `operator-webhook`) are created for the operator and webhook components, allowing them to interact with the Kubernetes API securely.

### Configuration
- **ConfigMap**: 
  - `config-logging`: Contains configuration for logging, including settings for log levels and output formats.
  - `config-observability`: Provides configuration for observability features, such as metrics backend destinations and logging URL templates.

### Networking
- **Secret**: `operator-webhook-certs` is created to store the TLS certificates for the operator's webhook, ensuring secure communication.

### Workload
- **Deployment**: The operator is deployed as part of the HelmRelease, managing the lifecycle of Knative resources.
- **ClusterRoleBinding** and **ClusterRole**: These resources grant the operator the necessary permissions to manage Knative resources across the cluster.

## Configuration Highlights
- The operator is configured to create or replace Custom Resource Definitions (CRDs) during installation and upgrades.
- The reconciliation interval for the HelmRelease is set to 10 minutes, ensuring that the state of the deployed resources is regularly checked and updated.
- Configurations for logging and observability can be customized through the `config-logging` and `config-observability` ConfigMaps.

## Deployment
- **Target Namespace**: `knative-serving`
- **Release Name**: `knative-operator`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: CRDs are created or replaced as needed, with a timeout of 10 minutes for the installation process.
