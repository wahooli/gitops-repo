---
title: "alerting"
parent: "Infrastructure / Alerting"
grand_parent: "nas"
---

# alerting

The `alerting` component is deployed in the `nas` cluster and is responsible for managing alerting rules and configurations using VictoriaMetrics and Alertmanager. This component includes several Kubernetes resources that facilitate alert routing, service discovery, and alert rules definition.

## Resources

### Namespaces
- **Namespace**: `alerting`
  - This namespace contains all resources related to the alerting functionality.

### Services
- **Service**: `vmalertmanager-tpi-1`
  - **Type**: ClusterIP
  - **Ports**:
    - HTTP: 9093 (target port: web)
    - TCP/UDP Mesh: 9094

### HTTP Routes
- **HTTPRoute**: `alertmanager`
  - **Hostnames**: `alertmanager.absolutist.it`
  - **Backend**: `vmalertmanager-nas` on port 9093

- **HTTPRoute**: `vmalert-vlogs`
  - **Hostnames**: `log-alerts.absolutist.it`
  - **Backend**: `vmalert-vlogs-nas` on port 8080

- **HTTPRoute**: `vmalert-vmetrics`
  - **Hostnames**: `metrics-alerts.absolutist.it`
  - **Backend**: `vmalert-vmetrics-nas` on port 8080

### Alert Rules
- **VMRule**: `smartctl-rules`
  - Contains rules for monitoring smart device temperatures and critical warnings.

- **VMRule**: `authentik-outpost-health`
  - Monitors the health of Authentik outposts.

- **VMRule**: `kubernetes-apps`
  - Monitors various Kubernetes application states, including pod readiness and deployment statuses.

- **VMRule**: `kubernetes-resources`
  - Monitors resource usage in the Kubernetes cluster, including CPU and memory overcommitment.

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
  - **Policy**: Semver range for versioning.

- **ImageRepository**: `alertmanager`
  - **Image**: `prom/alertmanager`
  - **Update Interval**: 24h

- **ImagePolicy**: `vmalertmanager`
  - **Policy**: Semver range for versioning.

### ConfigMaps
- **ConfigMap**: `vmalert-templates`
  - Contains templates for Grafana URLs for logs and metrics.

## Summary
The `alerting` component integrates various resources to provide a comprehensive alerting solution within the Kubernetes cluster. It leverages VictoriaMetrics for metrics collection and Alertmanager for alert routing, ensuring that alerts are effectively managed and communicated.
