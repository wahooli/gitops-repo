---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# kube-state-metrics

## Overview
`kube-state-metrics` is a service that listens to the Kubernetes API server and generates metrics about the state of the various objects in the cluster. It is typically used in conjunction with Prometheus for monitoring Kubernetes clusters.

## Deployment Details
- **Namespace**: `kube-system`
- **Release Name**: `kube-state-metrics`
- **Chart Version**: `7.2.2`
- **Source Repository**: `prometheus-community`
- **Update Interval**: 10 minutes for HelmRelease, 24 hours for ImageRepository and ImagePolicy.

## Resources Created
The following resources are created as part of the `kube-state-metrics` deployment:

1. **HelmRelease**: Manages the deployment of the kube-state-metrics chart.
2. **ImageRepository**: Tracks the image repository for kube-state-metrics.
3. **ImagePolicy**: Defines the policy for image updates.

## Configuration
The configuration for `kube-state-metrics` is managed through two ConfigMaps:
- `kube-state-metrics-values-52k4bbt862` with keys `values-base.yaml` and `values.yaml`.

### Key Configuration Options
- **Prometheus Scrape**: Enabled by default.
- **Replicas**: Set to `1`.
- **Service Type**: `ClusterIP` (default).
- **RBAC**: RBAC resources are created, and the service account is configured to use a ClusterRole.
- **Collectors**: All available collectors are enabled by default, including deployments, pods, services, and more.

### Security Context
- **Run As User**: `65534`
- **Run As Group**: `65534`
- **FS Group**: `65534`
- **Seccomp Profile**: `RuntimeDefault`

### Probes
- **Liveness Probe**: Configured to check the health of the application.
- **Readiness Probe**: Ensures the application is ready to serve traffic.

## Dependencies
`kube-state-metrics` depends on the `prometheus-operator--prometheus-operator-crds` for proper functioning.

## Monitoring
Metrics can be scraped by Prometheus, and additional configurations for monitoring can be set in the `values.yaml` file.

## Additional Features
- **Custom Resource State**: Enabled to allow monitoring of custom resources.
- **Vertical Pod Autoscaler Support**: Currently disabled but can be enabled if needed.

This deployment is part of the `infrastructure-platform` kustomization managed by Flux CD.
