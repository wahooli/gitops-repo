---
title: "monitoring"
parent: "Infrastructure / Monitoring"
grand_parent: "nas"
---

# monitoring

The `monitoring` component is deployed in the `nas` cluster and utilizes VictoriaMetrics for metrics collection and monitoring. This deployment includes several key resources for scraping metrics from various services and nodes within the cluster.

## Resources Overview

### HTTPRoute
- **Name**: `vmauth-global-write`
- **Namespace**: `monitoring`
- **Hostnames**: 
  - `vm-write.wahoo.li`
  - `vm-write.absolutist.it`
- **Backend Reference**: 
  - Service: `vmauth-global-write` on port `8427`

### Image Repositories and Policies
The following image repositories and policies are defined for the VictoriaMetrics components:

1. **vmselect**
   - **Image**: `victoriametrics/vmselect`
   - **Image Policy**: `vmselect-cluster`
   - **Version**: `v1.146.0-cluster`

2. **vminsert**
   - **Image**: `victoriametrics/vminsert`
   - **Image Policy**: `vminsert-cluster`
   - **Version**: `v1.146.0-cluster`

3. **vmstorage**
   - **Image**: `victoriametrics/vmstorage`
   - **Image Policy**: `vmstorage-cluster`
   - **Version**: `v1.146.0-cluster`

4. **vmagent**
   - **Image**: `victoriametrics/vmagent`
   - **Image Policy**: `vmagent`
   - **Version**: `latest`

### VMCluster
- **Name**: `long-term`
- **Namespace**: `monitoring`
- **Replication Factor**: `1`
- **Retention Period**: `12`
- **Components**:
  - **vminsert**: 
    - Image: `victoriametrics/vminsert:v1.146.0-cluster`
    - Replica Count: `1`
  - **vmselect**: 
    - Image: `victoriametrics/vmselect:v1.146.0-cluster`
    - Replica Count: `1`
    - Storage: `2Gi`
  - **vmstorage**: 
    - Image: `victoriametrics/vmstorage:v1.146.0-cluster`
    - Replica Count: `1`

### Services
Several services are created to expose the metrics endpoints:
- **vmagent-tpi-1**: Exposes port `8429`
- **vmclusterlb-short-term-tpi-1**: Exposes port `8427`
- **vminsert-short-term-tpi-1-server**: Exposes port `8480`
- **vmstorage-short-term-tpi-1-server**: Exposes ports `8482`, `8401`, and `8400`
- **vmstorage-short-term-tpi-1**: Exposes the same ports as above

### VMNodeScrape
Multiple `VMNodeScrape` resources are defined to scrape metrics from various sources:
- **cadvisor**
- **kubelet**
- **probes**
- **resources**

### VMPodScrape
Pod scraping configurations are defined for:
- **cert-manager**
- **fluxcd**
- **node-exporter**
- **topolvm**
- **envoy-gateway-proxy**

### VMServiceScrape
Service scraping configurations are defined for:
- **authentik**
- **envoy-gateway-controller**
- **kube-dns**
- **kube-state-metrics**
- **velero**
- **victoria-metrics-operator**

### VMStaticScrape
Static scraping configurations are defined for:
- **vps-node-exporter**
- **vps-haproxy**
- **vps-cert-metrics**

## Namespace
- **Namespace**: `monitoring`
- **Labels**: 
  - `internal-services: true`

This comprehensive setup ensures that metrics are collected from various components within the Kubernetes cluster, providing visibility into the performance and health of the applications and infrastructure.
