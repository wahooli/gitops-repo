---
title: "node-exporter"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# node-exporter

## Overview
The `node-exporter` component is responsible for exposing metrics about the node's hardware and operating system. It runs as a DaemonSet in the `kube-system` namespace, ensuring that an instance of the exporter runs on each node in the cluster. This component is essential for monitoring node performance and health, providing data that can be scraped by Prometheus.

## Dependencies
The `node-exporter` HelmRelease depends on the `prometheus-operator--prometheus-operator-crds`, which provides the necessary Custom Resource Definitions (CRDs) for Prometheus to function correctly. This dependency is crucial for integrating the metrics collected by `node-exporter` into the Prometheus monitoring system.

## Helm Chart(s)
- **Chart Name**: prometheus-node-exporter
- **Repository**: prometheus-community (https://prometheus-community.github.io/helm-charts)
- **Version**: 4.56.1

## Resource Glossary
### Networking
- **Service**: A `ClusterIP` service named `node-exporter` is created to expose the metrics endpoint on port 9100. This allows Prometheus to scrape metrics from the node-exporter instances running on each node.

### Security
- **ServiceAccount**: A service account named `node-exporter` is created to provide the necessary permissions for the DaemonSet to operate securely.

### Workload
- **DaemonSet**: The `node-exporter` DaemonSet ensures that the node-exporter runs on every node in the cluster. It is configured to use host networking and mounts host paths to access system metrics.

## Configuration Highlights
- **Extra Arguments**: The node-exporter is configured with several extra arguments to exclude specific filesystem mount points and devices from being monitored, ensuring that only relevant metrics are collected.
- **Security Context**: The DaemonSet runs containers with a non-root user and has a read-only root filesystem for enhanced security.
- **Probes**: Liveness and readiness probes are configured to ensure the node-exporter is healthy and ready to serve metrics.

## Deployment
- **Target Namespace**: kube-system
- **Release Name**: node-exporter
- **Reconciliation Interval**: 10 minutes
- **Install Behavior**: The installation is configured to retry indefinitely in case of failure.
