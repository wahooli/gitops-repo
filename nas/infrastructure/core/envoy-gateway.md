---
title: "envoy-gateway"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# envoy-gateway

## Overview

The `envoy-gateway` component deploys the Envoy Gateway, a Kubernetes-native API Gateway built on top of the Envoy Proxy. It provides advanced traffic management capabilities, including load balancing, routing, and observability, and serves as a controller for Gateway API resources in the cluster. This deployment is managed using Flux and Helm, ensuring automated and declarative management of the gateway.

## Helm Chart(s)

### envoy-gateway-system--envoy-gateway
- **Chart Name**: `gateway-helm`
- **Repository**: `envoy-gateway` (OCI: `oci://docker.io/envoyproxy`)
- **Version**: `v1.7.1`

## Resource Glossary

The `envoy-gateway` component creates the following Kubernetes resources:

### Namespace
- **`envoy-gateway-system`**: The namespace where all resources for the Envoy Gateway are deployed.

### ServiceAccount
- **`envoy-gateway`**: A service account used by the Envoy Gateway deployment for accessing Kubernetes resources.

### ConfigMaps
- **`envoy-gateway-config`**: Contains the configuration for the Envoy Gateway, including gateway controller settings, logging levels, and provider-specific configurations.
- **`envoy-gateway-values-4fg88chh89`**: Stores Helm values for the deployment, including base configuration, deployment replicas, and optional overrides.

### Deployment
- **`envoy-gateway`**: The main workload for the Envoy Gateway. It runs a single replica of the Envoy Gateway controller by default.

### Service
- **`envoy-gateway`**: Exposes the Envoy Gateway deployment to the cluster or external traffic, enabling communication with the gateway.

### RBAC Resources
- **ClusterRole**: Grants the Envoy Gateway permissions to manage Gateway API resources, Kubernetes resources (e.g., ConfigMaps, Secrets, Services), and other necessary objects.
- **ClusterRoleBinding**: Binds the ClusterRole to the `envoy-gateway` ServiceAccount.
- **Role**: Provides namespace-scoped permissions for managing resources within the `envoy-gateway-system` namespace.
- **RoleBinding**: Binds the Role to the `envoy-gateway` ServiceAccount within the namespace.

## Configuration Highlights

Key configuration settings for the `envoy-gateway` deployment include:

- **Gateway Controller Name**: `gateway.envoyproxy.io/gatewayclass-controller`
- **Logging Level**: Default logging level is set to `info`.
- **Replicas**: The deployment is configured to run with `1` replica by default.
- **Rate Limit Deployment**: Configured with the image `docker.io/envoyproxy/ratelimit:c8765e89` and `IfNotPresent` image pull policy.
- **Shutdown Manager**: Uses the image `docker.io/envoyproxy/gateway:v1.7.1`.

These settings are sourced from the `envoy-gateway-values-4fg88chh89` ConfigMap.

## Deployment

- **Target Namespace**: `envoy-gateway-system`
- **Release Name**: `envoy-gateway`
- **Reconciliation Interval**: 10 minutes
- **Install Behavior**: Creates or replaces Custom Resource Definitions (CRDs) during installation.
- **Upgrade Behavior**: Automatically remediates the last failure and replaces CRDs during upgrades.

This deployment is managed by Flux using a HelmRelease resource, ensuring continuous reconciliation and automated updates. Configuration values are sourced from a ConfigMap, allowing for easy customization and overrides.
