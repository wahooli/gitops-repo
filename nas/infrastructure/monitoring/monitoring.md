---
title: "monitoring"
parent: "Infrastructure / Monitoring"
grand_parent: "nas"
---

# monitoring

The `monitoring` component is deployed in the `nas` cluster and is responsible for collecting and managing metrics from various services within the Kubernetes environment. It utilizes VictoriaMetrics for long-term storage and scraping of metrics.

## Components

### VMCluster
- **Kind**: `VMCluster`
- **Version**: `v1.148.0-cluster`
- **Namespace**: `monitoring`
- **Spec**:
  - **Replication Factor**: 1
  - **Retention Period**: 12 months
  - **Components**:
    - **vminsert**: 
      - Image: `victoriametrics/vminsert:v1.148.0-cluster`
      - Replica Count: 1
    - **vmselect**: 
      - Image: `victoriametrics/vmselect:v1.148.0-cluster`
      - Replica Count: 1
      - Storage: 2Gi
    - **vmstorage**: 
      - Image: `victoriametrics/vmstorage:v1.148.0-cluster`
      - Replica Count: 1
      - Volume Mounts: `/storage`

### Services
- **Namespace**: `monitoring`
- **Services**:
  - `vmagent-tpi-1`: Exposes metrics on port 8429.
  - `vmclusterlb-short-term-tpi-1`: Exposes metrics on port 8427.
  - `vminsert-short-term-tpi-1-server`: Exposes metrics on port 8480.
  - `vmstorage-short-term-tpi-1-server`: Exposes multiple metrics ports (8482, 8401, 8400).
  - `vmstorage-short-term-tpi-1`: Exposes multiple metrics ports (8482, 8401, 8400).

### HTTPRoute
- **Name**: `vmauth-global-write`
- **Namespace**: `monitoring`
- **Spec**:
  - **Hostnames**: 
    - `vm-write.wahoo.li`
    - `vm-write.absolutist.it`
  - **Backend Reference**: 
    - `vmauth-global-write` on port 8427.

### Image Repositories and Policies
- **Image Repositories**:
  - `vmselect`, `vminsert`, `vmstorage`, `vmagent`: All set to check for new images every 24 hours.
- **Image Policies**:
  - Each image repository has a corresponding policy to manage versioning based on semantic versioning.

### VMNodeScrape
- **Node Scrapes**:
  - Configured for `cadvisor`, `kubelet`, `probes`, and `resources` with a scrape interval of 30 seconds.
  - Each node scrape has specific relabeling and dropping configurations to filter metrics.

### VMPodScrape
- **Pod Scrapes**:
  - Configured for `cert-manager`, `fluxcd`, `node-exporter`, `topolvm`, and `envoy-gateway-proxy` to scrape metrics from specific namespaces and pods.

### VMServiceScrape
- **Service Scrapes**:
  - Configured for `authentik`, `envoy-gateway-controller`, `kube-dns`, `kube-state-metrics`, `velero`, and `victoria-metrics-operator` to scrape metrics from various services across different namespaces.

### VMStaticScrape
- **Static Scrapes**:
  - Configured for `vps-node-exporter`, `vps-haproxy`, and `vps-cert-metrics` to scrape metrics from specified static targets.

## Notes
- The `monitoring` component is essential for observability within the Kubernetes cluster, providing insights into the performance and health of various services.
- Ensure that the necessary permissions and configurations are in place for scraping metrics from the specified endpoints.
