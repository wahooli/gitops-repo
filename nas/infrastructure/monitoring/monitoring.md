---
title: "monitoring"
parent: "Infrastructure / Monitoring"
grand_parent: "nas"
---

# monitoring

The `monitoring` component is deployed in the `nas` cluster and utilizes VictoriaMetrics for metrics collection and monitoring. This deployment includes various services, scrapes, and configurations to ensure comprehensive monitoring of the Kubernetes environment.

## Components

### VMCluster
- **Name**: `long-term`
- **Namespace**: `monitoring`
- **Image**: 
  - `vminsert`: `victoriametrics/vminsert:v1.148.0-cluster`
  - `vmselect`: `victoriametrics/vmselect:v1.148.0-cluster`
  - `vmstorage`: `victoriametrics/vmstorage:v1.148.0-cluster`
- **Replication Factor**: 1
- **Retention Period**: 12 days
- **Services**:
  - `vminsert`: Exposes metrics on port 8480.
  - `vmselect`: Exposes metrics on port 8401.
  - `vmstorage`: Exposes metrics on ports 8400, 8482.

### Image Repositories and Policies
- **Image Repositories**:
  - `vmselect`: `victoriametrics/vmselect` (24h interval)
  - `vminsert`: `victoriametrics/vminsert` (24h interval)
  - `vmstorage`: `victoriametrics/vmstorage` (24h interval)
  - `vmagent`: `victoriametrics/vmagent` (24h interval)

- **Image Policies**:
  - `vmselect-cluster`, `vminsert-cluster`, `vmstorage-cluster`: Policies to manage image versions based on semantic versioning.

### Services
- **Service Names**:
  - `vmagent-tpi-1`: Exposes metrics on port 8429.
  - `vmclusterlb-short-term-tpi-1`: Exposes metrics on port 8427.
  - `vminsert-short-term-tpi-1-server`: Exposes metrics on port 8480.
  - `vmstorage-short-term-tpi-1-server`: Exposes metrics on ports 8482, 8401, and 8400.
  - `vmstorage-short-term-tpi-1`: Exposes metrics on ports 8482, 8401, and 8400.

### Scraping Configurations
- **VMNodeScrape**:
  - `cadvisor`, `kubelet`, `probes`, `resources`: Configured to scrape metrics from various Kubernetes components every 30 seconds.
  
- **VMPodScrape**:
  - `cert-manager`, `fluxcd`, `node-exporter`, `topolvm`, `envoy-gateway-proxy`: Configured to scrape metrics from specific pods in their respective namespaces.

- **VMServiceScrape**:
  - `authentik`, `envoy-gateway-controller`, `kube-dns`, `kube-state-metrics`, `velero`, `victoria-metrics-operator`: Configured to scrape metrics from services across different namespaces.

### HTTPRoute
- **Name**: `vmauth-global-write`
- **Namespace**: `monitoring`
- **Hostnames**: 
  - `vm-write.wahoo.li`
  - `vm-write.absolutist.it`
- **Backend Reference**: Points to `vmauth-global-write` service on port 8427.

### Namespace
- **Name**: `monitoring`
- **Labels**: 
  - `internal-services`: "true"

This setup ensures robust monitoring capabilities across the Kubernetes cluster, leveraging VictoriaMetrics for efficient metrics collection and storage.
