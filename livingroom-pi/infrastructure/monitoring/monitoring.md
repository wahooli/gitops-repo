---
title: "monitoring"
parent: "Infrastructure / Monitoring"
grand_parent: "livingroom-pi"
---

# Monitoring

## Overview

The `monitoring` component is responsible for collecting, processing, and exposing metrics from various sources within the `livingroom-pi` Kubernetes cluster. It is deployed in the `monitoring` namespace and leverages VictoriaMetrics components to enable robust monitoring and observability. This component includes configurations for scraping metrics from nodes, pods, and services, as well as a centralized agent for forwarding metrics to a remote write endpoint.

## Helm Chart(s)

This component does not use HelmReleases. Instead, it is deployed using Kustomize with custom resource definitions (CRDs) provided by the VictoriaMetrics operator.

## Resource Glossary

### Networking
- **Service (`vmauth-global-write`)**:  
  A `ClusterIP` service in the `monitoring` namespace that exposes the VictoriaMetrics authentication endpoint on port `8427`. This service is globally accessible due to the `service.cilium.io/global: "true"` annotation.

### Monitoring
- **VMNodeScrape**:  
  Custom resources that define scraping configurations for collecting metrics from Kubernetes nodes. The following `VMNodeScrape` resources are deployed:
  - `cadvisor`: Scrapes metrics from the `/metrics/cadvisor` endpoint on nodes.
  - `kubelet`: Scrapes metrics from the kubelet's `/metrics` endpoint.
  - `probes`: Scrapes metrics from the `/metrics/probes` endpoint.
  - `resources`: Scrapes resource-related metrics from the `/metrics/resource` endpoint.

- **VMPodScrape**:  
  Custom resources that define scraping configurations for collecting metrics from specific pods. The following `VMPodScrape` resources are deployed:
  - `cert-manager`: Scrapes metrics from the `cert-manager` namespace for components such as `cainjector`, `controller`, and `webhook`.
  - `fluxcd`: Scrapes metrics from the `flux-system` namespace for Flux controllers.
  - `node-exporter`: Scrapes metrics from `node-exporter` pods in the `kube-system` namespace.

- **VMServiceScrape**:  
  Custom resources that define scraping configurations for collecting metrics from specific services. The following `VMServiceScrape` resources are deployed:
  - `kube-dns`: Scrapes metrics from the `kube-dns` service in the `kube-system` namespace.
  - `kube-state-metrics`: Scrapes metrics from the `kube-state-metrics` service in the `kube-system` namespace.
  - `victoria-metrics-operator`: Scrapes metrics from the VictoriaMetrics operator in the `victoria-metrics` namespace.

- **VMAgent (`livingroom-pi`)**:  
  A VictoriaMetrics Agent responsible for scraping metrics from the cluster and forwarding them to the `vmauth-global-write` service. It is configured with a scrape interval of `30s`, resource limits (CPU: `1000m`, Memory: `350Mi`), and external labels (e.g., `clustername: livingroom-pi`). The agent uses the `victoriametrics/vmagent:v1.108.1` image.

### Namespace
- **Namespace (`monitoring`)**:  
  The `monitoring` namespace is created to house all resources related to the monitoring stack. It is labeled with `internal-services: "true"` for organizational purposes.

## Configuration Highlights

- **VMAgent Configuration**:
  - Image: `victoriametrics/vmagent:v1.108.1`
  - Resource Requests: CPU `500m`, Memory `200Mi`
  - Resource Limits: CPU `1000m`, Memory `350Mi`
  - Scrape Interval: `30s`
  - Remote Write Endpoint: `http://vmauth-global-write.monitoring.svc.cluster.local.:8427/prometheus/api/v1/write`
  - External Labels: `clustername: livingroom-pi`

- **VMNodeScrape and VMPodScrape**:
  - Configured to scrape metrics from nodes, pods, and services at `30s` intervals.
  - Extensive use of `metricRelabelConfigs` and `relabelConfigs` to filter and transform metrics.

- **Service Configuration**:
  - `vmauth-global-write` service is exposed as a `ClusterIP` service on port `8427` with global accessibility enabled via Cilium annotations.

## Deployment

- **Target Namespace**: `monitoring`
- **Reconciliation**: Managed by Flux with the `infrastructure-monitoring` Kustomization in the `flux-system` namespace.
- **Install/Upgrade Behavior**: Resources are reconciled automatically by Flux based on the Kustomize configuration. Configuration changes can be made by modifying the Kustomize manifests and committing them to the GitOps repository.
