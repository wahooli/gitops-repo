---
title: "alerting"
parent: "Infrastructure / Alerting"
grand_parent: "tpi-1"
---

# alerting

The `alerting` component is deployed in the `tpi-1` cluster and is responsible for managing alerting rules and notifications using VictoriaMetrics and Alertmanager. It includes various configurations for monitoring and alerting on different services and metrics.

## Kubernetes Resources

### Namespace
- **Name:** `alerting`
- **Purpose:** Contains all resources related to the alerting functionality.

### Services
- **Service Name:** `vmalertmanager-nas`
  - **Type:** ClusterIP
  - **Ports:**
    - HTTP: 9093
    - TCP/UDP Mesh: 9094

### HTTP Routes
1. **Alertmanager**
   - **Hostname:** `alertmanager.${domain_absolutist_it}`
   - **Backend:** `vmalertmanager-tpi-1` on port 9093

2. **VMAlert Vlogs**
   - **Hostname:** `log-alerts.${domain_absolutist_it}`
   - **Backend:** `vmalert-vlogs-tpi-1` on port 8080

3. **VMAlert VMetrics**
   - **Hostname:** `metrics-alerts.${domain_absolutist_it}`
   - **Backend:** `vmalert-vmetrics-tpi-1` on port 8080

### Alerting Rules
- **VMRule Resources:**
  - **docker-mailserver:** Monitors login failures, service down alerts, and mail deferrals.
  - **authentik-outpost-health:** Monitors the health of the Authentik outpost.
  - **kubernetes-apps:** Monitors various Kubernetes application states, including pod health and deployment status.
  - **kubernetes-resources:** Monitors resource utilization and quotas in the Kubernetes cluster.

### Alertmanager Configurations
- **VMAlertmanagerConfig Resources:**
  - **generic-alerts:** Configures alert routing and receivers for generic alerts.
  - **systemd-alerts:** Configures alert routing and receivers for systemd-related alerts.

### Image Repositories and Policies
- **Image Repositories:**
  - **vmalert:** Uses the image `victoriametrics/vmalert`.
  - **alertmanager:** Uses the image `prom/alertmanager`.

- **Image Policies:**
  - **vmalert:** Policy for versioning the `vmalert` image.
  - **vmalertmanager:** Policy for versioning the `alertmanager` image.

### ConfigMaps
- **vmalert-templates:** Contains templates for Grafana URLs used in alerts.

## Summary
The `alerting` component is a comprehensive setup for monitoring and alerting within the `tpi-1` cluster, utilizing VictoriaMetrics and Alertmanager to provide robust alerting capabilities across various services and metrics.
