---
title: "grafana"
parent: "Apps"
grand_parent: "nas"
---

# Grafana

## Overview

Grafana is deployed in the `nas` cluster to provide monitoring and visualization capabilities. It is configured using FluxCD and Helm, leveraging the official Grafana Helm chart version `8.8.2`. The deployment includes custom configurations for dashboards, datasources, and authentication.

---

## Namespace

Grafana is deployed in the `grafana` namespace, which is labeled for internal services and excluded from certain backup operations.

---

## Helm Chart

### Chart Information
- **Chart Name**: `grafana`
- **Version**: `8.8.2`
- **Repository**: [Grafana Helm Charts](https://grafana.github.io/helm-charts)

### Release Configuration
- **Release Name**: `grafana`
- **Target Namespace**: `grafana`
- **Interval**: 5 minutes
- **Install Remediation**: Unlimited retries, timeout of 5 minutes
- **Upgrade Remediation**: Enabled, retries last failure

### Values Configuration
Custom values are provided via a ConfigMap named `grafana-values-7dd2d675c9`. Key configurations include:
- **Sidecar**:
  - Datasources and dashboards are managed via sidecars.
- **Ingress**:
  - Enabled with annotations for SSL redirection and external DNS.
  - Host: `grafana.wahoo.li`
- **Authentication**:
  - OAuth-based login using Authentik.
  - Login form disabled; auto-login enabled.
- **Plugins**:
  - Support for unsigned plugins: `victoriametrics-datasource` and `victoriametrics-logs-datasource`.
- **Grafana.ini**:
  - Configured for JSON logging, dark theme, and OAuth settings.

---

## Datasources

Datasources are managed via a ConfigMap named `victoria-metrics-datasource-84792bh299`. Key datasources include:
- **VictoriaMetrics-prometheus**:
  - Type: Prometheus
  - URL: `http://vmauth-read-proxy.monitoring.svc.cluster.local.:8427/select/0/prometheus/`
  - Default: Yes
- **VictoriaMetrics - read-proxy**:
  - Type: VictoriaMetrics
  - URL: `http://vmauth-read-proxy.monitoring.svc.cluster.local.:8427/select/0/prometheus/`
- **VictoriaLogs - distributed**:
  - Type: VictoriaMetrics Logs
  - URL: `http://vmauth-read-proxy.logging.svc.cluster.local.:9428`
- **VictoriaLogs - long term**:
  - Type: VictoriaMetrics Logs
  - URL: `http://vlsingle-long-term-nas.logging.svc.cluster.local.:9428`

---

## Dashboards

Dashboards are managed via sidecars and include configurations for CoreDNS monitoring. Example panels:
- **CoreDNS - Health Status**:
  - Displays the health status of CoreDNS instances.
- **CoreDNS - CPU Usage**:
  - Monitors CPU usage by instance.
- **CoreDNS - Memory Usage**:
  - Tracks memory usage by instance.
- **CoreDNS - DNS Requests**:
  - Visualizes total DNS requests and average packet sizes.

---

## Service Scraping

A `VMServiceScrape` resource is configured to scrape metrics from Grafana services. Key configurations:
- **Endpoints**:
  - Port: `service`
- **Selector**:
  - Labels: `app.kubernetes.io/instance: grafana`, `app.kubernetes.io/name: grafana`

---

## Authentication

Grafana is integrated with Authentik for OAuth-based authentication. Key settings:
- **Client ID/Secret**:
  - Loaded from a secret mounted at `/etc/secrets/auth_generic_oauth`.
- **OAuth URLs**:
  - Authorization: `https://auth.wahoo.li/application/o/authorize/`
  - Token: `https://auth.wahoo.li/application/o/token/`
  - User Info: `https://auth.wahoo.li/application/o/userinfo/`
- **Role Mapping**:
  - Maps user groups to Grafana roles (Admin, Editor, Viewer).

---

## Plugins

Grafana is configured to load the following plugins:
- **VictoriaMetrics Datasource**:
  - Version: `v0.10.3`
- **VictoriaMetrics Logs Datasource**:
  - Version: `v0.13.1`

---

## Ingress

Ingress is enabled with the following settings:
- **Host**: `grafana.wahoo.li`
- **Annotations**:
  - SSL redirection: Enabled
  - Proxy body size: `25m`
  - Read/Send timeout: `3600s`
  - External DNS target: `gw.wahoo.li`

---

## Notes

- The deployment uses FluxCD for GitOps-based management.
- Custom dashboards and datasources are automatically managed via sidecars.
- Ensure the required secrets for OAuth authentication are properly configured in the cluster.
