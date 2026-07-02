---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# kube-state-metrics

## Overview
`kube-state-metrics` is a service that listens to the Kubernetes API server and generates metrics about the state of the objects. It is typically used in conjunction with Prometheus to monitor the health and performance of Kubernetes clusters.

## Deployment Details
- **Namespace**: `kube-system`
- **Release Name**: `kube-state-metrics`
- **Chart Version**: `7.5.1`
- **Source Repository**: `prometheus-community`
- **Update Interval**: Every 10 minutes for the HelmRelease, and every 24 hours for the ImageRepository.

## Components
### HelmRelease
The `kube-state-metrics` is deployed as a HelmRelease with the following specifications:
- **Chart**: `kube-state-metrics`
- **Target Namespace**: `kube-system`
- **Values**: Loaded from two ConfigMaps (`kube-state-metrics-values-52k4bbt862`), which include configurations for RBAC, service settings, and metrics collection.

### ImageRepository
An ImageRepository is defined to track the image used by `kube-state-metrics`:
- **Image**: `ghcr.io/prometheus-community/charts/kube-state-metrics`
- **Update Interval**: Every 24 hours.

### ImagePolicy
An ImagePolicy is set to manage the versioning of the `kube-state-metrics` image:
- **Policy**: Semantic versioning range is defined as `x.x.x`.

## Configuration Values
The following key configurations are defined in the `values.yaml`:

- **RBAC**: 
  - `create`: true
  - `useClusterRole`: true
  - `extraRules`: Additional permissions for Flux resources.

- **Service**:
  - `port`: 8080
  - `type`: ClusterIP

- **Replicas**: 1

- **Collectors**: Enabled for various Kubernetes resources including pods, services, deployments, etc.

- **Security Context**:
  - `runAsUser`: 65534
  - `runAsGroup`: 65534
  - `fsGroup`: 65534

- **Probes**:
  - **Liveness Probe**: Configured to check the health of the application.
  - **Readiness Probe**: Configured to ensure the application is ready to serve traffic.

## Dependencies
The deployment of `kube-state-metrics` depends on the `prometheus-operator--prometheus-operator-crds` which must be installed in the same namespace.

## Monitoring
`kube-state-metrics` can be monitored using Prometheus by scraping the metrics endpoint exposed by the service. The service is configured to allow Prometheus to scrape metrics for monitoring purposes.

## Additional Notes
- The deployment is configured to use RBAC for security, ensuring that the service has the necessary permissions to access Kubernetes resources.
- The `autosharding` feature is disabled, and the deployment uses a single replica for simplicity.

This documentation provides a concise overview of the `kube-state-metrics` deployment in the `livingroom-pi` cluster, detailing its configuration, components, and operational parameters.
