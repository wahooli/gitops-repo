---
title: "monitoring"
parent: "Infrastructure / Monitoring"
grand_parent: "nas"
---

# monitoring

The `monitoring` component is deployed in the `nas` cluster and utilizes VictoriaMetrics for metrics collection and monitoring. It consists of several sub-components, including VMCluster, VMNodeScrape, and VMServiceScrape, which are configured to scrape metrics from various sources within the Kubernetes environment.

## Sub-components

### VMCluster
- **Name**: `long-term`
- **Namespace**: `monitoring`
- **Image**: 
  - `vminsert`: `victoriametrics/vminsert:v1.140.0-cluster`
  - `vmselect`: `victoriametrics/vmselect:v1.140.0-cluster`
  - `vmstorage`: `victoriametrics/vmstorage:v1.140.0-cluster`
- **Replication Factor**: 1
- **Retention Period**: 12 months
- **Service Specifications**: 
  - All services are of type `ClusterIP` with specific annotations for Cilium.

### VMNodeScrape
- **Scrapes**:
  - `cadvisor`: Scrapes metrics from cAdvisor.
  - `kubelet`: Scrapes metrics from the Kubelet.
  - `probes`: Scrapes metrics from probe endpoints.
  - `resources`: Scrapes resource metrics.
- **Interval**: 30 seconds
- **Bearer Token**: Uses service account token for authentication.

### VMPodScrape
- **Scrapes**:
  - `cert-manager`: Scrapes metrics from the cert-manager pods.
  - `fluxcd`: Scrapes metrics from FluxCD components.
  - `node-exporter`: Scrapes metrics from the node-exporter.
  - `topolvm`: Scrapes metrics from TopoLVM components.
  - `envoy-gateway-proxy`: Scrapes metrics from Envoy Gateway proxy.
- **Job Labels**: Various labels are used to identify the jobs.

### VMServiceScrape
- **Scrapes**:
  - `authentik`: Scrapes metrics from the Authentik service.
  - `envoy-gateway-controller`: Scrapes metrics from the Envoy Gateway controller.
  - `kube-dns`: Scrapes metrics from CoreDNS.
  - `kube-state-metrics`: Scrapes metrics from kube-state-metrics.
  - `velero`: Scrapes metrics from Velero.
  - `victoria-metrics-operator`: Scrapes metrics from the VictoriaMetrics operator.
  
### VMStaticScrape
- **Scrapes**:
  - `vps-node-exporter`: Scrapes metrics from static node exporters.
  - `vps-haproxy`: Scrapes metrics from HAProxy instances.
  - `vps-cert-metrics`: Scrapes certificate metrics from specified targets.

## Services
- **Services**:
  - `vmagent-tpi-1`: Exposes metrics on port 8429.
  - `vmclusterlb-short-term-tpi-1`: Exposes metrics on port 8427.
  - `vminsert-short-term-tpi-1-server`: Exposes metrics on port 8480.
  - `vmstorage-short-term-tpi-1-server`: Exposes multiple metrics ports.

## HTTPRoute
- **Name**: `vmauth-global-write`
- **Namespace**: `monitoring`
- **Hostnames**: 
  - `vm-write.wahoo.li`
  - `vm-write.absolutist.it`
- **Backend Reference**: Points to `vmauth-global-write` service on port 8427.

## Image Repositories and Policies
- **Image Repositories**: 
  - `vmselect`, `vminsert`, `vmstorage`, `vmagent` with a 24-hour update interval.
- **Image Policies**: 
  - Policies defined for each image repository to manage versioning and updates.

This setup provides a comprehensive monitoring solution for the Kubernetes cluster, ensuring that metrics are collected, stored, and made available for analysis and alerting.
