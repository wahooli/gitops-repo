---
title: "node-exporter"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# node-exporter

## Overview
The `node-exporter` component is responsible for exposing metrics about the node's hardware and operating system, which can be scraped by Prometheus for monitoring purposes. It runs as a DaemonSet, ensuring that an instance of the exporter runs on each node in the Kubernetes cluster.

## Dependencies
The `node-exporter` HelmRelease has a dependency on the `prometheus-operator--prometheus-operator-crds`, which provides the necessary Custom Resource Definitions (CRDs) for Prometheus to function correctly in the cluster.

## Helm Chart(s)
- **Chart Name**: prometheus-node-exporter
- **Repository**: prometheus-community (https://prometheus-community.github.io/helm-charts)
- **Version**: 4.53.1

## Resource Glossary
### Security
- **ServiceAccount**: The `node-exporter` ServiceAccount is created to provide an identity for the node-exporter pods, allowing them to interact with the Kubernetes API securely.

### Networking
- **Service**: A ClusterIP Service named `node-exporter` is created to expose the metrics endpoint on port 9100. This allows Prometheus to scrape metrics from the node-exporter instances.

### Workload
- **DaemonSet**: The `node-exporter` DaemonSet ensures that a pod runs on each node in the cluster. It is configured to collect metrics from the host system and exposes them via the defined Service. The DaemonSet uses host networking and mounts host paths to access system information.

## Configuration Highlights
- **Extra Arguments**: The node-exporter is configured with several extra arguments to exclude certain filesystem mount points and devices from being monitored, as well as to format logs in JSON.
- **Host Networking**: The DaemonSet is configured to use host networking, allowing it to access host resources directly.
- **Security Context**: The pods run with a non-root user and have a read-only root filesystem for enhanced security.
- **Probes**: Liveness and readiness probes are configured to ensure the node-exporter is running and ready to serve metrics.

## Deployment
- **Target Namespace**: kube-system
- **Release Name**: node-exporter
- **Reconciliation Interval**: 10 minutes
- **Install Behavior**: The installation is configured with a retry strategy for remediation, allowing for automatic retries in case of failure.
