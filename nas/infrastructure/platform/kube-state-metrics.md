---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kube-state-metrics

## Overview
`kube-state-metrics` is a service that listens to the Kubernetes API server and generates metrics about the state of the objects. It is designed to be used with Prometheus for monitoring Kubernetes clusters.

## Deployment Details
- **Namespace**: `flux-system`
- **Target Namespace**: `kube-system`
- **Release Name**: `kube-state-metrics`
- **Chart Version**: `7.3.0`
- **Source Repository**: `prometheus-community`

## HelmRelease Configuration
The `kube-state-metrics` deployment is managed by a `HelmRelease` resource with the following specifications:

- **Interval**: 10 minutes for updates.
- **Dependencies**: It depends on the `prometheus-operator--prometheus-operator-crds` in the `flux-system` namespace.
- **Values Configuration**: The deployment uses values from two ConfigMaps:
  - `kube-state-metrics-values-52k4bbt862` (keys: `values-base.yaml`, `values.yaml`)

## Image Configuration
- **Image Repository**: `ghcr.io/prometheus-community/charts/kube-state-metrics`
- **Image Policy**: The image policy is set to track versions using semantic versioning.

## Key Features
- **Prometheus Scraping**: Enabled by default.
- **RBAC**: Role-based access control is configured to allow the necessary permissions for the service.
- **Service Type**: The service is exposed as a `ClusterIP` by default, allowing internal access within the cluster.
- **Metrics Collection**: Collects metrics from various Kubernetes resources including deployments, pods, services, and more.

## Configuration Values
The following are notable configuration values used in the deployment:

- **Replicas**: 1
- **Service Port**: 8080
- **Autosharding**: Disabled
- **Extra Arguments**: None specified
- **Security Context**: Configured to run as a non-root user with specific security settings.

## Additional Information
For further customization, users can modify the values in the associated ConfigMaps or adjust the HelmRelease specifications as needed. The kube-state-metrics service can be monitored via Prometheus, and additional metrics can be configured through the `metricAllowlist` and `metricDenylist` settings. 

For more details on kube-state-metrics, refer to the official [kube-state-metrics documentation](https://github.com/kubernetes/kube-state-metrics).
