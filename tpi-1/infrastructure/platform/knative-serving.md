---
title: "knative-serving"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# knative-serving

## Overview
Knative Serving is a Kubernetes component that provides the ability to deploy and manage serverless workloads. It enables automatic scaling of applications, including scaling down to zero, and supports routing and traffic management. This deployment is part of the infrastructure platform for the cluster `tpi-1`.

## Sub-components
This deployment does not contain multiple HelmReleases.

## Dependencies
This deployment does not have any specified dependencies.

## Helm Chart(s)
- **Chart Name:** knative-serving
- **Repository:** operator.knative.dev
- **Version:** 1.21.1

## Resource Glossary
### Networking
- **KnativeServing:** The main resource that configures the Knative Serving component, including settings for domain, timeout, and feature flags.
- **Service (net-gateway-api-webhook):** Exposes the webhook for the net-gateway-api, allowing it to receive and process admission requests.
- **ValidatingWebhookConfiguration:** Configures the webhook to validate incoming requests for the net-gateway-api.

### Security
- **ClusterRole (knative-gateway-api-admin):** Provides administrative access for the Knative Serving component, though no specific rules are defined.
- **ClusterRole (knative-gateway-api-core):** Grants permissions to manage gateway resources, including HTTP routes and reference policies.

### Workloads
- **Deployment (net-gateway-api-controller):** Runs the controller for the net-gateway-api, responsible for managing the lifecycle of gateway resources.
- **Deployment (net-gateway-api-webhook):** Runs the webhook server that handles admission requests for the net-gateway-api.

### Configuration
- **ConfigMap (config-gateway):** Stores configuration for external and local gateways, specifying supported features.

### Secrets
- **Secret (net-gateway-api-webhook-certs):** Holds certificates for the webhook to ensure secure communication.

## Configuration Highlights
- **Resource Requests/Limits:** 
  - Controller: Requests 100m CPU and 100Mi memory; limits 1000m CPU and 1000Mi memory.
  - Webhook: Requests 20m CPU and 20Mi memory; limits 200m CPU and 200Mi memory.
- **Replicas:** Both deployments are set to 1 replica.
- **Environment Variables:** 
  - SYSTEM_NAMESPACE: Automatically set to the namespace of the deployment.
  - CONFIG_LOGGING_NAME and CONFIG_OBSERVABILITY_NAME: Set to `config-logging` and `config-observability`, respectively.
  - METRICS_DOMAIN: Set to `knative.dev/net-gateway-api`.

## Deployment
- **Target Namespace:** knative-serving
- **Release Name:** knative-serving
- **Reconciliation Interval:** Not specified in the manifests.
- **Install/Upgrade Behavior:** Not specified in the manifests.
