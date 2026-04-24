---
title: "knative-serving"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# knative-serving

## Overview
Knative Serving is a component of the Knative framework that enables the deployment and management of serverless workloads on Kubernetes. It provides features such as automatic scaling, traffic splitting, and revision management for applications. In this deployment, Knative Serving is configured to work with the Gateway API for ingress management.

## Sub-components
This deployment does not have multiple HelmReleases.

## Dependencies
This deployment does not have any dependencies specified.

## Helm Chart(s)
- **Chart Name**: knative-serving
- **Repository**: knative.dev
- **Version**: 1.21.1

## Resource Glossary
### Networking
- **KnativeServing**: The primary resource that configures the Knative Serving component, including settings for domain, ingress class, and feature flags.
- **Deployment**: Two deployments are created:
  - **net-gateway-api-controller**: Manages the controller for the Gateway API, responsible for handling HTTP routes and ingress traffic.
  - **net-gateway-api-webhook**: Provides a webhook for validating configurations related to the Gateway API.
- **Service**: Exposes the webhook deployment, allowing it to receive traffic on specified ports for metrics and profiling.
- **ValidatingWebhookConfiguration**: Configures the admission controller to validate incoming requests to the Gateway API.

### Security
- **ClusterRole**: Two roles are created to manage permissions for the Gateway API controller and its components, allowing it to interact with Gateway API resources.
- **Secret**: Stores certificates for the webhook to ensure secure communication.

### Configuration
- **ConfigMap**: Contains configuration details for external and local gateways, specifying supported features for the Gateway API.

## Configuration Highlights
- **Resource Requests/Limits**: 
  - `net-gateway-api-controller`: Requests 100m CPU and 100Mi memory; limits 1000m CPU and 1000Mi memory.
  - `net-gateway-api-webhook`: Requests 20m CPU and 20Mi memory; limits 200m CPU and 200Mi memory.
- **Replicas**: The deployments are configured with a single replica.
- **Environment Variables**: Key environment variables include `SYSTEM_NAMESPACE`, `CONFIG_LOGGING_NAME`, and `METRICS_DOMAIN`, which are essential for the operation of the Knative Serving components.

## Deployment
- **Target Namespace**: knative-serving
- **Release Name**: knative-serving
- **Reconciliation Interval**: Not specified in the manifests.
- **Install/Upgrade Behavior**: Not specified in the manifests.
