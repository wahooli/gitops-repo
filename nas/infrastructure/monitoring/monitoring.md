---
title: "monitoring"
parent: "Infrastructure / Monitoring"
grand_parent: "nas"
---

# monitoring

The `monitoring` component is deployed in the `nas` cluster and is responsible for collecting and managing metrics using VictoriaMetrics and related tools. This deployment includes several key resources and configurations to ensure effective monitoring of the cluster.

## Namespace
- **Namespace**: `monitoring`
  - This namespace is dedicated to all monitoring-related resources.

## HTTPRoute
- **Name**: `vmauth-global-write`
  - **Hostnames**: 
    - `vm-write.wahoo.li`
    - `vm-write.absolutist.it`
  - **Backend**: 
    - Points to the service `vmauth-global-write` on port `8427`.

## Image Repositories and Policies
The following image repositories and policies are configured to manage the images for the monitoring components:

1. **Image Repository**: `vmselect`
   - **Image**: `victoriametrics/vmselect`
   - **Update Interval**: 24h

2. **Image Policy**: `vmselect-cluster`
   - **Filter Tags**: Matches versions in the format `vX.Y.Z-cluster`.

3. **Image Repository**: `vminsert`
   - **Image**: `victoriametrics/vminsert`
   - **Update Interval**: 24h

4. **Image Policy**: `vminsert-cluster`
   - **Filter Tags**: Matches versions in the format `vX.Y.Z-cluster`.

5. **Image Repository**: `vmstorage`
   - **Image**: `victoriametrics/vmstorage`
   - **Update Interval**: 24h

6. **Image Policy**: `vmstorage-cluster`
   - **Filter Tags**: Matches versions in the format `vX.Y.Z-cluster`.

7. **Image Repository**: `vmagent`
   - **Image**: `victoriametrics/vmagent`
   - **Update Interval**: 24h

8. **Image Policy**: `vmagent`
   - **Filter Tags**: Matches versions in the format `vX.Y.Z`.

## VMCluster
- **Name**: `long-term`
  - **Image Tags**: 
    - `vminsert`: `v1.136.0-cluster`
    - `vmselect`: `v1.136.0-cluster`
    - `vmstorage`: `v1.136.0-cluster`
  - **Replication Factor**: 1
  - **Retention Period**: 12 months
  - **Service Specifications**: All services are configured with `ClusterIP` type and specific annotations for Cilium.

## Services
The following services are created to expose the monitoring components:

1. **Service**: `vmagent-tpi-1`
   - **Port**: 8429

2. **Service**: `vmclusterlb-short-term-tpi-1`
   - **Port**: 8427

3. **Service**: `vminsert-short-term-tpi-1-server`
   - **Port**: 8480

4. **Service**: `vmstorage-short-term-tpi-1-server`
   - **Ports**: 
     - 8482 (http)
     - 8401 (vmselect)
     - 8400 (vminsert)

5. **Service**: `vmstorage-short-term-tpi-1`
   - **Ports**: 
     - 8482 (http)
     - 8401 (vmselect)
     - 8400 (vminsert)

## VMNodeScrape
Multiple `VMNodeScrape` resources are configured to scrape metrics from various sources:

- **Node Scrapes**: 
  - `cadvisor`, `kubelet`, `probes`, `resources` are configured to scrape metrics from nodes at a 30s interval.
  
## VMPodScrape
Pod-level scraping is configured for various applications including:

- **Pod Scrapes**: 
  - `cert-manager`, `fluxcd`, `node-exporter`, `topolvm`, `envoy-gateway-proxy` are set up to collect metrics from specific namespaces and applications.

## VMServiceScrape
Service-level scraping is configured for services such as:

- **Service Scrapes**: 
  - `authentik`, `envoy-gateway-controller`, `kube-dns`, `kube-state-metrics`, `velero`, `victoria-metrics-operator` are set up to scrape metrics from services across different namespaces.

## VMStaticScrape
Static scraping configurations are set for specific targets:

- **Static Scrapes**: 
  - `vps-node-exporter`, `vps-haproxy`, `vps-cert-metrics` are configured to scrape metrics from predefined static endpoints.

This comprehensive setup ensures that the monitoring component effectively collects, processes, and exposes metrics for the applications running in the `nas` cluster.
