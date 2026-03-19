---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kube-state-metrics

## Overview
The `kube-state-metrics` component is deployed in the `nas` cluster to provide Kubernetes cluster state metrics for monitoring and observability. It is managed using FluxCD and HelmRelease resources.

## Helm Chart Details
- **Chart Name**: `kube-state-metrics`
- **Version**: `7.2.0`
- **Source Repository**: `prometheus-community`
- **Release Name**: `kube-state-metrics`
- **Target Namespace**: `kube-system`

## Dependencies
This deployment depends on the following HelmRelease:
- **Name**: `prometheus-operator--prometheus-operator-crds`
- **Namespace**: `flux-system`

## Configuration
The deployment is configured using values from two ConfigMaps:
- **ConfigMap Name**: `kube-state-metrics-values-52k4bbt862`
  - **Key**: `values-base.yaml`
  - **Key**: `values.yaml`

### Key Configuration Highlights
- **Prometheus Scrape**: Enabled (`prometheusScrape: true`)
- **RBAC**: Enabled (`rbac.create: true`)
- **Replicas**: `1`
- **Service Type**: `ClusterIP`
- **Pod Security Context**:
  - `runAsUser`: `65534`
  - `runAsGroup`: `65534`
  - `fsGroup`: `65534`
  - `runAsNonRoot`: `true`
- **Collectors**: Metrics for various Kubernetes resources are enabled, including:
  - Pods, Deployments, Services, Nodes, PersistentVolumes, etc.

### Custom Resource State Metrics
The deployment is configured to collect custom resource state metrics for FluxCD resources, including:
- `Kustomization`
- `HelmRelease`
- `GitRepository`
- `Bucket`
- `HelmRepository`
- `HelmChart`

These metrics provide detailed insights into the state of GitOps Toolkit resources.

## Image Management
- **Image Repository**: `ghcr.io/prometheus-community/charts/kube-state-metrics`
- **Image Policy**: SemVer range `x.x.x` for automatic updates.

## Update Strategy
- **Install Remediation**: Unlimited retries (`retries: -1`)
- **Interval**: `10m`

## Additional Features
- **Custom Resource State**: Enabled with specific configurations for monitoring GitOps Toolkit resources.
- **Pod Security Policy**: Disabled.
- **Network Policy**: Disabled.
- **Self-Monitoring**: Disabled.
- **Vertical Pod Autoscaler**: Disabled.

## Probes
- **Liveness Probe**: Configured with a 5-second initial delay.
- **Readiness Probe**: Configured with a 5-second initial delay.
- **Startup Probe**: Disabled.

## Deployment Strategy
- **Update Strategy**: Default is `RollingUpdate`.

## Resource Management
- **Resource Requests and Limits**: Not explicitly defined, allowing flexibility for deployment in resource-constrained environments.

## Additional Notes
- The deployment uses FluxCD annotations and labels for integration with the GitOps workflow.
- The `kube-state-metrics` chart is configured to provide metrics for monitoring Kubernetes resources and custom GitOps Toolkit resources, enabling comprehensive observability for the cluster.

For more details on the configuration options, refer to the [kube-state-metrics documentation](https://github.com/kubernetes/kube-state-metrics).
