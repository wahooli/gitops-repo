---
title: "node-exporter"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# node-exporter

## Overview
The `node-exporter` component is responsible for exposing hardware and OS metrics from the nodes in the Kubernetes cluster. It collects various metrics related to system performance and resource usage, which can be scraped by monitoring tools like Prometheus. This deployment is crucial for monitoring the health and performance of the cluster.

## Dependencies
The `node-exporter` HelmRelease has a dependency on the `prometheus-operator--prometheus-operator-crds`, which provides the necessary Custom Resource Definitions (CRDs) for Prometheus monitoring. This dependency ensures that the monitoring infrastructure is properly set up before deploying the node exporter.

## Helm Chart(s)
- **Chart Name**: prometheus-node-exporter
- **Repository**: prometheus-community (https://prometheus-community.github.io/helm-charts)
- **Version**: 4.55.0

## Resource Glossary
### Security
- **ServiceAccount**: A dedicated service account named `node-exporter` is created to provide the necessary permissions for the node exporter to run.

### Networking
- **Service**: A `ClusterIP` service named `node-exporter` is created to expose the metrics endpoint on port 9100. This allows Prometheus to scrape metrics from the node exporter.

### Compute
- **DaemonSet**: A `DaemonSet` named `node-exporter` ensures that an instance of the node exporter runs on each node in the cluster. It collects metrics from the host system and exposes them for monitoring.

## Configuration Highlights
- **Extra Arguments**: The node exporter is configured with several extra arguments to exclude certain filesystem mount points and devices from being monitored, which helps in reducing noise in the metrics.
- **Security Context**: The container runs as a non-root user with a read-only root filesystem for enhanced security.
- **Host Networking**: The node exporter runs in host network mode, allowing it to access host metrics directly.
- **Probes**: Liveness and readiness probes are configured to ensure the node exporter is running correctly and is ready to serve metrics.

## Deployment
- **Target Namespace**: kube-system
- **Release Name**: node-exporter
- **Reconciliation Interval**: 10 minutes
- **Install Behavior**: The installation will retry indefinitely in case of failure, ensuring that the node exporter is always running.
