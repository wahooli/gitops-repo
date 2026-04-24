---
title: "knative-serving"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# knative-serving

## Overview
Knative Serving is a Kubernetes component that enables the deployment and management of serverless workloads. It provides the ability to run and scale applications based on demand, allowing developers to focus on writing code without worrying about the underlying infrastructure. In this deployment, Knative Serving is configured to use the Gateway API for ingress management.

## Sub-components
This deployment does not include multiple HelmReleases.

## Dependencies
This deployment does not have any specified dependencies.

## Helm Chart(s)
- **Chart Name**: knative-serving
- **Repository**: knative.dev
- **Version**: 1.21.1

## Resource Glossary
### Networking
- **KnativeServing**: The primary resource that configures Knative Serving, including settings for domain, timeout, and feature flags.
- **Deployment (net-gateway-api-controller)**: Manages the controller for the Gateway API, ensuring that HTTP routes and policies are handled correctly.
- **Deployment (net-gateway-api-webhook)**: Manages the webhook for validating incoming requests to the Gateway API.
- **Service (net-gateway-api-webhook)**: Exposes the webhook deployment, allowing it to receive and respond to admission requests.
- **ValidatingWebhookConfiguration**: Configures the Kubernetes admission controller to use the webhook for validating resources related to the Gateway API.

### Security
- **ClusterRole (knative-gateway-api-admin)**: Provides administrative access to the Gateway API resources.
- **ClusterRole (knative-gateway-api-core)**: Grants permissions to manage Gateway API resources like HTTP routes and gateways.
- **Secret (net-gateway-api-webhook-certs)**: Stores the TLS certificates for the webhook service to secure communication.

### Configuration
- **ConfigMap (config-gateway)**: Contains configuration details for external and local gateways, specifying supported features.

## Configuration Highlights
- **Timeout Settings**: `max-revision-timeout-seconds` and `revision-timeout-seconds` are both set to 9000 seconds.
- **Ingress Class**: Configured to use `gateway-api.ingress.networking.knative.dev`.
- **Resource Requests/Limits**: 
  - `net-gateway-api-controller`: Requests 100m CPU and 100Mi memory; limits 1000m CPU and 1000Mi memory.
  - `net-gateway-api-webhook`: Requests 20m CPU and 20Mi memory; limits 200m CPU and 200Mi memory.
- **Replicas**: The `net-gateway-api-controller` is set to 1 replica.

## Deployment
- **Target Namespace**: knative-serving
- **Release Name**: knative-serving
- **Reconciliation Interval**: Not specified in the manifests.
- **Install/Upgrade Behavior**: Not specified in the manifests.
