---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# kube-state-metrics

## Overview
`kube-state-metrics` is a service that listens to the Kubernetes API server and generates metrics about the state of the objects. It is designed to be used with Prometheus for monitoring Kubernetes clusters.

## Deployment Details
- **Release Name**: `kube-state-metrics`
- **Namespace**: `kube-system`
- **Helm Chart Version**: `7.3.0`
- **Source Repository**: `prometheus-community`
- **Update Interval**: 10 minutes for HelmRelease, 24 hours for ImageRepository

## Dependencies
- Depends on `prometheus-operator--prometheus-operator-crds` in the `flux-system` namespace.

## Configuration
The deployment is configured using two ConfigMaps:
1. `kube-state-metrics-values-52k4bbt862` with keys:
   - `values-base.yaml`
   - `values.yaml`

### Key Configuration Options
- **Replicas**: 1
- **Service Type**: ClusterIP
- **Prometheus Scrape**: Enabled
- **RBAC**: Enabled with ClusterRole permissions
- **Service Account**: Created with automount of API credentials

### Metrics Collection
The following Kubernetes resources are monitored:
- Pods, Services, Deployments, StatefulSets, DaemonSets, and more.

### Security Context
- Run as non-root user (UID 65534)
- Read-only root filesystem
- Seccomp profile set to `RuntimeDefault`

## Image Details
- **Image Repository**: `ghcr.io/prometheus-community/charts/kube-state-metrics`
- **Image Policy**: Semver policy applied for version control.

## Probes
- **Liveness Probe**: Configured to check the health of the application.
- **Readiness Probe**: Ensures the application is ready to serve traffic.

## Additional Features
- Support for custom resource state metrics.
- Vertical Pod Autoscaler support (disabled by default).
- Self-monitoring capabilities (disabled by default).

## Notes
- The deployment is part of the `flux-system` namespace and is managed using Flux CD for GitOps practices.
- Ensure that the Prometheus operator is correctly configured to scrape metrics from `kube-state-metrics`.
