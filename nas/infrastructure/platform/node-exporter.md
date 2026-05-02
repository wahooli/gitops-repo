---
title: "node-exporter"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# node-exporter

## Overview
The `node-exporter` component is responsible for exposing hardware and OS metrics from the nodes in the Kubernetes cluster. It collects various system metrics and makes them available for scraping by monitoring systems like Prometheus. This deployment consists of a single HelmRelease that manages the installation of the Prometheus Node Exporter.

## Dependencies
The `node-exporter` HelmRelease has a dependency on the `prometheus-operator--prometheus-operator-crds`, which provides the necessary Custom Resource Definitions (CRDs) for Prometheus to function correctly in the cluster.

## Helm Chart(s)
- **Chart Name:** prometheus-node-exporter
- **Repository:** prometheus-community (https://prometheus-community.github.io/helm-charts)
- **Version:** 4.55.0

## Resource Glossary
### Security
- **ServiceAccount:** A service account named `node-exporter` is created in the `kube-system` namespace to provide an identity for the node-exporter pods.

### Networking
- **Service:** A ClusterIP service named `node-exporter` is created to expose the metrics endpoint on port 9100. This service allows Prometheus to scrape metrics from the node-exporter pods.

### Workload
- **DaemonSet:** A DaemonSet named `node-exporter` is deployed in the `kube-system` namespace. This ensures that a node-exporter pod runs on each node in the cluster, collecting metrics from the host system. The DaemonSet is configured to use host networking and mounts host paths for `/proc`, `/sys`, and the root filesystem to access system metrics.

## Configuration Highlights
- **Extra Arguments:** The node-exporter is configured with several command-line arguments to exclude certain filesystem mount points and devices from being monitored, as well as to specify logging format.
- **Host Networking:** The node-exporter pods run in host network mode, allowing them to access host-level metrics directly.
- **Probes:** Liveness and readiness probes are configured to ensure the node-exporter is healthy and ready to serve metrics.

## Deployment
- **Target Namespace:** kube-system
- **Release Name:** node-exporter
- **Reconciliation Interval:** 10 minutes
- **Install Behavior:** The HelmRelease is set to retry indefinitely on failure, ensuring that the node-exporter is always running.
