---
title: "alerting"
parent: "Infrastructure / Alerting"
grand_parent: "nas"
---

# alerting

The `alerting` component is deployed in the `nas` cluster and is responsible for managing alerting rules and configurations using VictoriaMetrics and Alertmanager. It includes HTTP routes for alerting services, alert rules, and configurations for notifications.

## Kubernetes Resources

### Namespaces
- **Namespace**: `alerting`
  - This namespace is created to isolate the alerting resources.

### Services
- **Service**: `vmalertmanager-tpi-1`
  - **Type**: ClusterIP
  - **Ports**:
    - `http`: 9093 (TCP)
    - `tcp-mesh`: 9094 (TCP)
    - `udp-mesh`: 9094 (UDP)

### HTTP Routes
- **HTTPRoute**: `alertmanager`
  - **Hostname**: `alertmanager.absolutist.it`
  - **Backend**: `vmalertmanager-nas:9093`
  
- **HTTPRoute**: `vmalert-vlogs`
  - **Hostname**: `log-alerts.absolutist.it`
  - **Backend**: `vmalert-vlogs-nas:8080`
  
- **HTTPRoute**: `vmalert-vmetrics`
  - **Hostname**: `metrics-alerts.absolutist.it`
  - **Backend**: `vmalert-vmetrics-nas:8080`

### Alert Rules
- **VMRule**: `smartctl-rules`
  - Contains rules for monitoring smart device temperatures and critical warnings.

- **VMRule**: `authentik-outpost-health`
  - Monitors the health of Authentik outposts.

- **VMRule**: `kubernetes-apps`
  - Monitors various Kubernetes application states, including pod health and deployment statuses.

- **VMRule**: `kubernetes-resources`
  - Monitors resource usage and overcommitment in the Kubernetes cluster.

### Alertmanager Configurations
- **VMAlertmanagerConfig**: `generic-alerts`
  - Configures alert routing to Discord for generic alerts.

- **VMAlertmanagerConfig**: `systemd-alerts`
  - Configures alert routing to Discord for systemd-related alerts.

### Image Repositories and Policies
- **ImageRepository**: `vmalert`
  - **Image**: `victoriametrics/vmalert`
  - **Update Interval**: 24h

- **ImagePolicy**: `vmalert`
  - **Version Policy**: Semver matching for `v1.x.x`.

- **ImageRepository**: `alertmanager`
  - **Image**: `prom/alertmanager`
  - **Update Interval**: 24h

- **ImagePolicy**: `vmalertmanager`
  - **Version Policy**: Semver matching for `v0.x.x`.

### ConfigMaps
- **ConfigMap**: `vmalert-templates`
  - Contains templates for Grafana URLs for logs and metrics.

## Summary
The `alerting` component integrates various alerting mechanisms and configurations to monitor the health and performance of applications and infrastructure within the `nas` cluster. It utilizes VictoriaMetrics for alert rules and Alertmanager for notifications, specifically targeting Discord for alert delivery.
