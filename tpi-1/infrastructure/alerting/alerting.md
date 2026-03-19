---
title: "alerting"
parent: "Infrastructure / Alerting"
grand_parent: "tpi-1"
---

# Alerting

The `alerting` component is deployed in the `tpi-1` cluster and is responsible for managing alerting and monitoring configurations. It includes multiple sub-components for alerting and monitoring functionalities, primarily leveraging VictoriaMetrics and Prometheus Alertmanager.

---

## Overview

The `alerting` component is deployed in the `alerting` namespace and provides the following functionalities:

1. **Alertmanager**: Handles alert notifications and routing.
2. **VMAlert**: Manages alert rules and notifications for VictoriaMetrics.
3. **HTTPRoutes**: Configures HTTP routing for alerting services.
4. **VMRules**: Defines alerting rules for various use cases.
5. **Image Automation**: Manages container image versions for `vmalert` and `alertmanager`.

---

## Namespace

The `alerting` namespace is labeled as an internal service namespace and is managed by FluxCD.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: alerting
  labels:
    internal-services: "true"
    kustomize.toolkit.fluxcd.io/name: infrastructure-alerting
    kustomize.toolkit.fluxcd.io/namespace: flux-system
```

---

## Sub-Components

### Alertmanager

#### Description
The Alertmanager handles alert notifications and routing. It uses the `prom/alertmanager` container image, with the version managed by FluxCD's ImagePolicy.

#### Image Configuration
- **Image Repository**: `prom/alertmanager`
- **Image Policy**: Semantic versioning (`x.x.x`)

#### Service
The `vmalertmanager-nas` service is configured as a `ClusterIP` service with the following ports:
- `http`: Port 9093 (TCP)
- `tcp-mesh`: Port 9094 (TCP)
- `udp-mesh`: Port 9094 (UDP)

#### HTTPRoute
The `alertmanager` HTTPRoute exposes the Alertmanager service:
- **Hostname**: `alertmanager.${domain_absolutist_it:=absolutist.it}`
- **Parent Gateway**: `internal-gw` in the `infrastructure` namespace
- **Backend Service**: `vmalertmanager-tpi-1` on port 9093

#### Alertmanager Configurations
Two `VMAlertmanagerConfig` resources are defined:
1. **Generic Alerts**:
   - Receiver: Discord
   - Grouping by `alertgroup` and `alertname`
   - Group interval: 5 minutes
   - Repeat interval: 3 hours
   - Route for specific alerts (e.g., `SomeRemoteWriteTargetsFailing`)

2. **Systemd Alerts**:
   - Receiver: Discord
   - Grouping by `systemd_host` and `systemd_unit`
   - Group interval: 15 minutes
   - Repeat interval: 6 hours
   - Routes for journald-related alerts

---

### VMAlert

#### Description
VMAlert manages alert rules and notifications for VictoriaMetrics. It uses the `victoriametrics/vmalert` container image, with the version managed by FluxCD's ImagePolicy.

#### Image Configuration
- **Image Repository**: `victoriametrics/vmalert`
- **Image Policy**: Semantic versioning (`vX.X.X`)

#### HTTPRoutes
Two HTTPRoutes expose VMAlert services:
1. **vmalert-vlogs**:
   - **Hostname**: `log-alerts.${domain_absolutist_it:=absolutist.it}`
   - **Parent Gateway**: `internal-gw` in the `infrastructure` namespace
   - **Backend Service**: `vmalert-vlogs-tpi-1` on port 8080

2. **vmalert-vmetrics**:
   - **Hostname**: `metrics-alerts.${domain_absolutist_it:=absolutist.it}`
   - **Parent Gateway**: `internal-gw` in the `infrastructure` namespace
   - **Backend Service**: `vmalert-vmetrics-tpi-1` on port 8080

#### ConfigMap
The `vmalert-templates` ConfigMap contains templates for Grafana URLs for logs and metrics exploration.

---

### VM Rules

Several `VMRule` resources are defined for alerting:

1. **docker-mailserver**:
   - Alerts for login failures, Postfix downtime, and deferred mail.
   - Severity: Critical

2. **kubernetes-apps**:
   - Alerts for Kubernetes application issues such as pod crash loops, deployment mismatches, and stateful set issues.
   - Severity: Warning

3. **kubernetes-resources**:
   - Alerts for resource overcommitment, quota usage, and resource limits.
   - Severity: Warning/Info

---

## Image Automation

The `alerting` component uses FluxCD's Image Automation to manage container image versions for its sub-components:

1. **vmalert**:
   - **Image Repository**: `victoriametrics/vmalert`
   - **Policy**: Semantic versioning (`vX.X.X`)

2. **alertmanager**:
   - **Image Repository**: `prom/alertmanager`
   - **Policy**: Semantic versioning (`vX.X.X`)

---

## External DNS Configuration

The HTTPRoutes include annotations for external DNS configuration:
- **Target**: `gw.nas.${domain_absolutist_it:=absolutist.it}`

---

## Summary

The `alerting` component in the `tpi-1` cluster provides a robust alerting and monitoring solution using VictoriaMetrics and Prometheus Alertmanager. It is configured with multiple alert rules, routing configurations, and image automation policies to ensure efficient and scalable alert management.
