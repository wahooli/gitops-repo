---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kube-state-metrics

## Overview
`kube-state-metrics` is a service that listens to the Kubernetes API server and generates metrics about the state of various Kubernetes resources. It provides insights into the state of the cluster, which can be scraped by Prometheus for monitoring and alerting purposes.

## Deployment Details
- **Release Name:** kube-state-metrics
- **Target Namespace:** kube-system
- **Helm Chart Version:** 7.5.1
- **Source Repository:** prometheus-community
- **Update Interval:** 10 minutes
- **Dependencies:** 
  - `prometheus-operator--prometheus-operator-crds` (namespace: flux-system)

## Configuration
The deployment is configured using values from two ConfigMaps:
- `kube-state-metrics-values-52k4bbt862` (values-base.yaml)
- `kube-state-metrics-values-52k4bbt862` (values.yaml)

### Key Configuration Options
- **Prometheus Scraping:** Enabled
- **Replicas:** 1
- **Service Type:** ClusterIP
- **RBAC:** Enabled with a ClusterRole
- **Automount Service Account Token:** True
- **Collectors Enabled:** All available collectors including pods, services, deployments, etc.

### RBAC Configuration
The deployment includes RBAC permissions to allow `kube-state-metrics` to access the necessary Kubernetes resources. The extra rules defined in the values.yaml allow it to list and watch various GitOps Toolkit resources.

## Image Details
- **Image Repository:** ghcr.io/prometheus-community/charts/kube-state-metrics
- **Image Policy:** Set to follow semantic versioning.

## Probes
- **Liveness Probe:** Configured to check the health of the service.
- **Readiness Probe:** Ensures the service is ready to accept traffic.

## Additional Features
- **Self Monitoring:** Disabled by default.
- **Vertical Pod Autoscaler Support:** Disabled by default.
- **Custom Resource State Metrics:** Enabled with specific configurations for various resource types.

## Notes
- The deployment is designed to be resilient and can be configured further based on the specific needs of the cluster.
- For detailed metrics and scraping configurations, refer to the official [kube-state-metrics documentation](https://github.com/kubernetes/kube-state-metrics).
