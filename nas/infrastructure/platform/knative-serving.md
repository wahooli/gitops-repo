---
title: "knative-serving"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# knative-serving

## Overview
Knative Serving is a Kubernetes component that enables the deployment and management of serverless workloads. It provides the ability to run and scale applications based on incoming traffic, allowing for rapid development and deployment of cloud-native applications. In this deployment, Knative Serving is configured to use the Gateway API for ingress management.

## Sub-components
This deployment consists of the following sub-components:
- **Knative Serving**: Provides the core functionality for serving applications.
- **Net Gateway API**: Manages ingress traffic for Knative services.

## Dependencies
There are no explicit dependencies defined in this deployment.

## Helm Chart(s)
- **Knative Serving**
  - **Chart Name**: knative-serving
  - **Repository**: https://charts.helm.sh/knative
  - **Version**: 1.21.1

## Resource Glossary
### Networking
- **KnativeServing**: The main resource that configures Knative Serving, including domain settings, timeout configurations, and feature flags.
- **Service**: The `net-gateway-api-webhook` service exposes the webhook for the Net Gateway API, allowing it to handle incoming requests on specified ports.
- **ValidatingWebhookConfiguration**: Ensures that requests to the API server are validated against the rules defined in the webhook.

### Security
- **ClusterRole**: Defines permissions for the Net Gateway API components, allowing them to manage HTTP routes and gateways.
- **Secret**: Stores certificates for the `net-gateway-api-webhook`, ensuring secure communication.

### Workload
- **Deployment**: Two deployments are created:
  - `net-gateway-api-controller`: Runs the main controller for managing the Net Gateway API, handling traffic routing and metrics.
  - `net-gateway-api-webhook`: Manages the webhook for validating incoming requests, ensuring they conform to the expected specifications.

### Configuration
- **ConfigMap**: Stores configuration for external and local gateways, specifying supported features for routing.

## Configuration Highlights
- **Resource Requests/Limits**:
  - `net-gateway-api-controller`: Requests 100m CPU and 100Mi memory; limits 1000m CPU and 1000Mi memory.
  - `net-gateway-api-webhook`: Requests 20m CPU and 20Mi memory; limits 200m CPU and 200Mi memory.
- **Replicas**: The `net-gateway-api-controller` is set to run with 1 replica.
- **Environment Variables**: Key environment variables include `SYSTEM_NAMESPACE`, `CONFIG_LOGGING_NAME`, and `METRICS_DOMAIN`, which are essential for the operation of the components.

## Deployment
- **Target Namespace**: knative-serving
- **Release Name**: knative-serving
- **Reconciliation Interval**: Not specified in the manifests.
- **Install/Upgrade Behavior**: Not specified in the manifests.
