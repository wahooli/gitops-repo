---
title: "envoy-gateway"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# envoy-gateway

## Overview

The `envoy-gateway` component provides an implementation of the Kubernetes Gateway API using Envoy Proxy. It acts as a gateway controller, managing gateway resources and routing traffic based on the Gateway API specifications. This deployment is part of the `tpi-1` cluster and is configured to run in the `envoy-gateway-system` namespace.

## Helm Chart(s)

### HelmRelease: `envoy-gateway-system--envoy-gateway`
- **Chart Name**: `gateway-helm`
- **Repository**: `envoy-gateway` (OCI: `oci://docker.io/envoyproxy`)
- **Version**: `v1.7.1`

## Resource Glossary

### Networking
- **Service**: Exposes the `envoy-gateway` deployment to other services or external traffic.

### Workload
- **Deployment**: Manages the `envoy-gateway` application, ensuring two replicas are running for high availability. The deployment includes topology spread constraints to distribute pods across nodes for better fault tolerance.

### Configuration
- **ConfigMap**: Stores configuration for the `envoy-gateway`, including logging levels, gateway controller settings, and provider-specific configurations.

### Security
- **ServiceAccount**: Provides an identity for the `envoy-gateway` pods to interact with the Kubernetes API.
- **ClusterRole**: Grants permissions to manage Gateway API resources, including gateway classes, routes, and related configurations.
- **ClusterRoleBinding**: Binds the `ClusterRole` to the `ServiceAccount` for cluster-wide access.
- **Role**: Defines namespace-specific permissions for managing resources.
- **RoleBinding**: Binds the `Role` to the `ServiceAccount` for namespace-specific access.

## Configuration Highlights

- **Replicas**: The deployment is configured to run with 2 replicas for high availability.
- **Topology Spread Constraints**: Ensures pods are distributed across nodes to improve resilience.
- **Logging**: Default logging level is set to `info`.
- **Provider Configuration**: Configured to use Kubernetes as the provider, with specific settings for rate limiting and shutdown management.
- **Image Versions**:
  - Envoy Gateway: `v1.7.1`
  - Rate Limit Deployment: `docker.io/envoyproxy/ratelimit:c8765e89`

## Deployment

- **Target Namespace**: `envoy-gateway-system`
- **Release Name**: `envoy-gateway`
- **Reconciliation Interval**: 10 minutes
- **Install Behavior**: Creates or replaces CRDs during installation.
- **Upgrade Behavior**: Creates or replaces CRDs during upgrades, with remediation enabled to retry indefinitely and remediate the last failure.

This deployment is managed by Flux and uses a HelmRelease to ensure the desired state is maintained. Configuration values are sourced from a ConfigMap (`envoy-gateway-values-cmdgkmtfdk`) with multiple keys (`values-base.yaml`, `values.yaml`, and optionally `values-extra.yaml`).
