---
title: "smartctl-exporter"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# smartctl-exporter

## Overview
The `smartctl-exporter` is a monitoring component that collects and exposes metrics from storage devices using the `smartctl` command. It is deployed in the `kube-system` namespace and is designed to work alongside the Prometheus monitoring stack, providing insights into the health and performance of storage devices in the cluster.

## Dependencies
The `smartctl-exporter` has a dependency on the `prometheus-operator--prometheus-operator-crds`, which provides the necessary Custom Resource Definitions (CRDs) for Prometheus to function correctly. This dependency ensures that the metrics collected by the exporter can be scraped and processed by Prometheus.

## Helm Chart(s)
- **Chart Name:** prometheus-smartctl-exporter
- **Repository:** prometheus-community (https://prometheus-community.github.io/helm-charts)
- **Version:** 0.17.1

## Resource Glossary
### Networking
- **Service:** A `ClusterIP` service named `smartctl-exporter` is created to expose the metrics endpoint on port 80. This allows Prometheus to scrape metrics from the exporter.

### Security
- **ServiceAccount:** A service account named `smartctl-exporter` is created to provide the necessary permissions for the DaemonSet to run.
- **RoleBinding:** A role binding is established to associate the `smartctl-exporter` service account with the `unrestricted-psp` ClusterRole, allowing it to operate with the necessary privileges.

### Workload
- **DaemonSet:** A DaemonSet named `smartctl-exporter-0` is deployed to ensure that the exporter runs on every node in the cluster. It collects metrics from the storage devices on each node and exposes them for scraping.

## Configuration Highlights
- **Device Inclusion:** The exporter is configured to include devices matching the regex `sd.*|nvme.*`.
- **Metrics Endpoint:** The exporter listens on `0.0.0.0:9633` for metrics scraping.
- **Resource Requests/Limits:** Resource requests and limits are not explicitly defined, allowing the exporter to run with default resource settings.
- **Tolerations:** The DaemonSet includes tolerations to allow it to run on nodes with specific taints.

## Deployment
- **Target Namespace:** kube-system
- **Release Name:** smartctl-exporter
- **Reconciliation Interval:** 10 minutes
- **Install/Upgrade Behavior:** The HelmRelease is configured to retry indefinitely on failure, ensuring that the exporter remains deployed and operational.
