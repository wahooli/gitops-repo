---
title: "knative-operator"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# knative-operator

## Overview
The `knative-operator` component is responsible for managing the lifecycle of Knative Serving resources within the Kubernetes cluster. It automates the deployment and management of Knative components, enabling serverless capabilities on Kubernetes.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `knative-serving--knative-operator`
  - **Chart**: `knative-operator`
  - **Version**: `v1.21.1`
  - **Target Namespace**: `knative-serving`
  - **Provides**: Manages Knative Serving resources, including deployments, service accounts, and configuration maps.

## Dependencies
This component does not have any defined dependencies.

## Helm Chart(s)
- **Chart Name**: `knative-operator`
- **Repository**: [knative-operator](https://knative.github.io/operator)
- **Version**: `v1.21.1`

## Resource Glossary
- **Namespace**: `knative-serving`
  - A dedicated namespace for all Knative Serving resources.
  
- **ServiceAccount**: 
  - `knative-operator`: Used by the Knative operator to interact with the Kubernetes API.
  - `operator-webhook`: Used for the operator's webhook functionality.

- **Secret**: 
  - `operator-webhook-certs`: Holds the TLS certificates for the operator's webhook.

- **ConfigMap**: 
  - `config-logging`: Contains logging configuration options for Knative components.
  - `config-observability`: Contains observability configuration options, including logging and metrics settings.

- **ClusterRoleBinding**: Grants permissions to the operator to manage Knative resources across the cluster.

- **ClusterRole**: Defines the permissions for the operator to perform actions on Knative resources.

- **Deployment**: 
  - Two deployments are created to run the operator and its webhook.

- **CustomResourceDefinition**: Defines the custom resources that the operator manages.

- **Service**: Exposes the operator's webhook to handle incoming requests.

- **RoleBinding**: Binds the role to the service account for namespace-specific permissions.

- **Role**: Defines permissions for the operator within the `knative-serving` namespace.

## Configuration Highlights
- The operator is configured to create and replace Custom Resource Definitions (CRDs) during installation and upgrades.
- Configurations for logging and observability are provided through ConfigMaps, which can be customized as needed.
- The reconciliation interval for the HelmRelease is set to 10 minutes, ensuring that the state of the deployment is regularly checked and updated.

## Deployment
- **Target Namespace**: `knative-serving`
- **Release Name**: `knative-operator`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: CRDs are created or replaced as needed during installation and upgrades.
