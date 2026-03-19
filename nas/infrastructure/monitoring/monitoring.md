---
title: "monitoring"
parent: "Infrastructure / Monitoring"
grand_parent: "nas"
---

# Monitoring

The `monitoring` component in the `nas` cluster is responsible for providing observability and monitoring capabilities using VictoriaMetrics. This document outlines the deployed resources and their configurations.

---

## Overview

The `monitoring` component is deployed in the `monitoring` namespace and utilizes VictoriaMetrics for time-series data storage and monitoring. It includes various sub-components such as `VMCluster`, `VMAgent`, `VMAuth`, and multiple scrape configurations for collecting metrics from nodes, pods, and services.

---

## Deployed Resources

### Namespace
- **Name**: `monitoring`
- **Labels**:
  - `internal-services: "true"`
  - `kustomize.toolkit.fluxcd.io/name: infrastructure-monitoring`
  - `kustomize.toolkit.fluxcd.io/namespace: flux-system`

---

### HTTPRoute
- **Name**: `vmauth-global-write`
- **Namespace**: `monitoring`
- **Hostnames**:
  - `vm-write.wahoo.li`
  - `vm-write.absolutist.it`
- **ParentRefs**:
  - Name: `internal-gw`
  - Namespace: `infrastructure`
- **BackendRefs**:
  - Name: `vmauth-global-write`
  - Port: `8427`

---

### VictoriaMetrics Cluster Deployments

#### VMCluster: `long-term`
- **Namespace**: `monitoring`
- **Replication Factor**: `1`
- **Retention Period**: `12 months`
- **Components**:
  - **vminsert**:
    - **Image**: `victoriametrics/vminsert:v1.136.0-cluster`
    - **Replica Count**: `1`
    - **Service Type**: `ClusterIP`
  - **vmselect**:
    - **Image**: `victoriametrics/vmselect:v1.136.0-cluster`
    - **Replica Count**: `1`
    - **Service Type**: `ClusterIP`
    - **Storage**: `2Gi`
  - **vmstorage**:
    - **Image**: `victoriametrics/vmstorage:v1.136.0-cluster`
    - **Replica Count**: `1`
    - **Service Type**: `ClusterIP`
    - **Storage**: HostPath with dynamic path and type

#### VMCluster: `short-term-nas`
- **Namespace**: `monitoring`
- **Replication Factor**: `1`
- **Retention Period**: `3 months`
- **Components**:
  - **vminsert**:
    - **Image**: `victoriametrics/vminsert:v1.136.0-cluster`
    - **Replica Count**: `1`
    - **Service Type**: `ClusterIP`
  - **vmselect**:
    - **Image**: `victoriametrics/vmselect:v1.136.0-cluster`
    - **Replica Count**: `2`
    - **Service Type**: `ClusterIP`
    - **Storage**: `2Gi`
  - **vmstorage**:
    - **Image**: `victoriametrics/vmstorage:v1.136.0-cluster`
    - **Replica Count**: `1`
    - **Service Type**: `ClusterIP`
    - **Storage**: `20Gi`

---

### VMAgent: `nas`
- **Namespace**: `monitoring`
- **Image**: `victoriametrics/vmagent:v1.136.0`
- **Resources**:
  - **Limits**:
    - CPU: `650m`
    - Memory: `350Mi`
  - **Requests**:
    - CPU: `200m`
    - Memory: `200Mi`
- **Scrape Interval**: `30s`
- **Remote Write Endpoints**:
  - `http://vminsert-short-term-tpi-1-server.monitoring.svc.cluster.local.:8480/insert/0/prometheus/api/v1/write`
  - `http://vminsert-short-term-nas.monitoring.svc.cluster.local.:8480/insert/0/prometheus/api/v1/write`
  - `http://vminsert-long-term.monitoring.svc.cluster.local.:8480/insert/0/prometheus/api/v1/write`
  - `http://vmclusterlb-short-term-tpi-1.monitoring.svc.cluster.local.:8427/insert/0/prometheus/api/v1/write`

---

### VMAuth: `global-write`
- **Namespace**: `monitoring`
- **Port**: `8427`
- **Service Type**: `ClusterIP`
- **Unauthorized User Access**:
  - URL Map:
    - Paths: `/api/v1/write`, `/prometheus/api/v1/write`, `/write`, `/api/v1/import`
    - URL Prefixes:
      - `http://vmagent-nas.monitoring.svc.cluster.local.:8429`
      - `http://vmagent-tpi-1.monitoring.svc`

---

### Image Automation Resources
- **ImageRepository**:
  - `vmselect`: `victoriametrics/vmselect` (interval: 24h)
  - `vminsert`: `victoriametrics/vminsert` (interval: 24h)
  - `vmstorage`: `victoriametrics/vmstorage` (interval: 24h)
  - `vmagent`: `victoriametrics/vmagent` (interval: 24h)
- **ImagePolicy**:
  - `vmselect-cluster`: Semver range `x.x.x`, pattern `v(?P<version>[1-9]+\.[0-9]+\.[0-9]+)-cluster`
  - `vminsert-cluster`: Semver range `x.x.x`, pattern `v(?P<version>[1-9]+\.[0-9]+\.[0-9]+)-cluster`
  - `vmstorage-cluster`: Semver range `x.x.x`, pattern `v(?P<version>[1-9]+\.[0-9]+\.[0-9]+)-cluster`
  - `vmagent`: Semver range `x.x.x`, pattern `v(?P<version>[1-9]+\.[0-9]+\.[0-9]+)`

---

### Scrape Configurations

#### VMNodeScrape
- **cadvisor**: Scrapes metrics from `/metrics/cadvisor` with a 30s interval.
- **kubelet**: Scrapes metrics from `/metrics` with a 30s interval.
- **probes**: Scrapes metrics from `/metrics/probes` with a 30s interval.
- **resources**: Scrapes metrics from `/metrics/resource` with a 30s interval.

#### VMPodScrape
- **cert-manager**: Scrapes metrics from `cert-manager` namespace.
- **fluxcd**: Scrapes metrics from `flux-system` namespace.
- **node-exporter**: Scrapes metrics from `kube-system` namespace.
- **topolvm**: Scrapes metrics from `topolvm-system` namespace.

#### VMServiceScrape
- **authentik**: Scrapes metrics from `default` and `authentik` namespaces.
- **ingress-nginx**: Scrapes metrics from `ingress-nginx` namespace.
- **kube-dns**: Scrapes metrics from `kube-system` namespace.
- **kube-state-metrics**: Scrapes metrics from `kube-system` namespace.
- **victoria-metrics-operator**: Scrapes metrics from `victoria-metrics` namespace.

---

### Services
- `vmagent-tpi-1`: Exposes VMAgent on port `8429`.
- `vmclusterlb-short-term-tpi-1`: Load balancer for short-term VMCluster on port `8427`.
- `vminsert-short-term-tpi-1-server`: Exposes vminsert on port `8480`.
- `vmstorage-short-term-tpi-1-server`: Exposes vmstorage on ports `8482`, `8401`, and `8400`.
- `vmstorage-short-term-tpi-1`: Exposes vmstorage on ports `8482`, `8401`, and `8400`.

---

## Notes
- **VictoriaMetrics Version**: `v1.136.0-cluster` for all components.
- **Namespace**: All monitoring resources are deployed in the `monitoring` namespace unless otherwise specified.
- **Retention Periods**:
  - Long-term: 12 months
  - Short-term: 3 months
- **Scrape Interval**: 30 seconds for all scrape configurations.
- **Resource Requests and Limits**: Configured for `VMAgent` to optimize resource usage.

This setup ensures a robust monitoring solution with long-term and short-term data retention, efficient scraping configurations, and support for multiple namespaces and services.
