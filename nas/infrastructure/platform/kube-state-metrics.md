---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kube-state-metrics

## Overview
`kube-state-metrics` is a service that listens to the Kubernetes API server and generates metrics about the state of the objects. It is designed to be used with Prometheus to provide insights into the state of your Kubernetes cluster.

## Deployment Details
- **Namespace**: `kube-system`
- **Helm Chart Version**: `8.0.0`
- **Helm Repository**: `prometheus-community`
- **Release Name**: `kube-state-metrics`
- **Update Interval**: `10m`
- **Image Repository**: `ghcr.io/prometheus-community/charts/kube-state-metrics`
- **Image Policy Interval**: `24h`

## Configuration
The deployment is configured using values from two ConfigMaps:
1. `kube-state-metrics-values-52k4bbt862` (values-base.yaml)
2. `kube-state-metrics-values-52k4bbt862` (values.yaml)

### Key Configuration Options
- **Prometheus Scraping**: Enabled by default.
- **Replicas**: 1
- **Service Type**: ClusterIP
- **RBAC**: Enabled with a ClusterRole
- **Service Account**: Created by default
- **Metrics Collection**: Collects metrics from various Kubernetes resources including pods, deployments, services, etc.

### Additional Features
- **Autosharding**: Disabled by default.
- **Self-Monitoring**: Disabled by default.
- **Vertical Pod Autoscaler Support**: Disabled by default.

## Dependencies
This deployment depends on the `prometheus-operator--prometheus-operator-crds` resource.

## Security Context
- **Run As User**: 65534
- **Run As Group**: 65534
- **FS Group**: 65534
- **Read Only Root Filesystem**: True
- **Allow Privilege Escalation**: False

## Probes
- **Liveness Probe**: Configured to check the health of the application.
- **Readiness Probe**: Configured to ensure the application is ready to serve traffic.

## Resource Management
- **Resource Requests and Limits**: Not specified by default, allowing flexibility for resource allocation.

## Monitoring and Metrics
Metrics are exposed for various Kubernetes resources, and can be scraped by Prometheus for monitoring purposes. The configuration allows for customization of which metrics to collect and expose.

## Notes
- Ensure that the Prometheus server is configured to scrape metrics from the `kube-state-metrics` service.
- Review the values in the ConfigMaps for any custom configurations that may be necessary for your environment.
