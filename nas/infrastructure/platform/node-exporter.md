---
title: "node-exporter"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# node-exporter

## Overview
The `node-exporter` component is responsible for exposing metrics about the node's hardware and operating system, which are essential for monitoring and performance analysis in a Kubernetes cluster. It runs as a DaemonSet, ensuring that metrics are collected from each node in the cluster.

## Dependencies
The `node-exporter` HelmRelease depends on the `prometheus-operator--prometheus-operator-crds`, which provides the necessary Custom Resource Definitions (CRDs) for Prometheus to scrape metrics from the node-exporter.

## Helm Chart(s)
- **Chart Name:** prometheus-node-exporter
- **Repository:** prometheus-community (https://prometheus-community.github.io/helm-charts)
- **Version:** 4.53.1

## Resource Glossary
### Security
- **ServiceAccount:** A dedicated service account named `node-exporter` is created to manage permissions for the node-exporter pods.

### Networking
- **Service:** A ClusterIP service named `node-exporter` is created to expose the metrics endpoint on port 9100. It allows Prometheus to scrape metrics from the node-exporter.

### Workload
- **DaemonSet:** The `node-exporter` runs as a DaemonSet, ensuring that an instance of the node-exporter is deployed on each node in the cluster. It collects metrics from the host's filesystem, network interfaces, and other system components.

## Configuration Highlights
- **Extra Arguments:** The node-exporter is configured with several command-line arguments to exclude certain filesystem mount points and network devices from metrics collection.
- **Host Networking:** The node-exporter pods run in host network mode, allowing them to access the host's network stack.
- **Security Context:** The container runs as a non-root user with a read-only root filesystem for enhanced security.
- **Probes:** Liveness and readiness probes are configured to ensure the node-exporter is healthy and ready to serve metrics.

## Deployment
- **Target Namespace:** kube-system
- **Release Name:** node-exporter
- **Reconciliation Interval:** 10m
- **Install Behavior:** The HelmRelease is set to retry indefinitely on failure, ensuring that the node-exporter is always running.
