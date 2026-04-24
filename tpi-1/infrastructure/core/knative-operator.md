---
title: "knative-operator"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# knative-operator

## Overview
The Knative Operator is responsible for managing the lifecycle of Knative components in the Kubernetes cluster. It automates the installation, upgrade, and configuration of Knative Serving, enabling developers to build and deploy serverless applications on Kubernetes.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease:** knative-serving--knative-operator
  - **Chart:** knative-operator
  - **Version:** v1.21.1
  - **Target Namespace:** knative-serving
  - **Provides:** Management of Knative Serving components, including configuration and lifecycle management.

## Dependencies
This HelmRelease does not have any specified dependencies.

## Helm Chart(s)
- **Chart Name:** knative-operator
- **Repository:** knative-operator (https://knative.github.io/operator)
- **Version:** v1.21.1

## Resource Glossary
### Security
- **ServiceAccount:** Two service accounts (`knative-operator` and `operator-webhook`) are created in the `knative-serving` namespace to provide identity for the Knative operator and its webhook.

### Configuration
- **ConfigMap:** Two ConfigMaps (`config-logging` and `config-observability`) are created to manage logging and observability configurations for Knative components. These ConfigMaps contain example configurations that can be customized by users.

### Networking
- **Secret:** A secret named `operator-webhook-certs` is created to store certificates for the operator's webhook, ensuring secure communication.

### Roles and Permissions
- **ClusterRoleBinding:** Seven ClusterRoleBindings are created to grant the necessary permissions to the operator and its components.
- **ClusterRole:** Seven ClusterRoles define the permissions for the operator to manage Knative resources.
- **RoleBinding:** A RoleBinding is created to bind a role to a specific service account within the namespace.
- **Role:** A Role defines permissions for resources within the `knative-serving` namespace.

### Workload Management
- **Deployment:** Two Deployments are created to manage the lifecycle of the operator and its components, ensuring they are running and available.

### Custom Resource Definitions
- **CustomResourceDefinition:** Two CRDs are created to define the custom resources that the Knative operator manages.

## Configuration Highlights
- **CRDs:** Created or replaced during installation and upgrades.
- **Timeout:** Installation timeout is set to 10 minutes.
- **Post Renderers:** ConfigMaps for logging and observability are deleted to avoid conflicts with custom configurations.
- **Values:** Configuration values are sourced from multiple ConfigMaps, allowing for flexible customization.

## Deployment
- **Target Namespace:** knative-serving
- **Release Name:** knative-operator
- **Reconciliation Interval:** 10 minutes
- **Install Behavior:** CRDs are created or replaced, and the operator is installed with a timeout of 10 minutes.
- **Upgrade Behavior:** CRDs are also created or replaced during upgrades.
