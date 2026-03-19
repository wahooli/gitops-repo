---
title: "grafana"
parent: "Apps"
grand_parent: "tpi-1"
---

# Grafana

This document provides an overview of the Grafana deployment in the `tpi-1` cluster.

## Overview

Grafana is deployed in the `grafana` namespace using HelmRelease managed by Flux. The deployment uses the official Grafana Helm chart (`grafana`) version `8.8.2` sourced from the Grafana Helm repository.

## Namespace

The Grafana resources are deployed in the `grafana` namespace, which includes the following labels:
- `internal-services: "true"`
- `topolvm.io/webhook: ignore`

## Helm Chart

### HelmRepository

The Helm chart is sourced from the Grafana Helm repository:
- **URL**: `https://grafana.github.io/helm-charts`
- **Interval**: `24h`

### HelmRelease

The HelmRelease configuration includes:
- **Chart**: `grafana` version `8.8.2`
- **Release Name**: `grafana`
- **Target Namespace**: `grafana`
- **Install Remediation**: Unlimited retries (`-1`) with a timeout of `5m`.
- **Upgrade Remediation**: Enabled to remediate the last failure.
- **Values Source**: ConfigMap `grafana-values-7dd2d675c9` (key: `values.yaml`).

## Configuration

### ConfigMap: `grafana-values-7dd2d675c9`

The `values.yaml` file contains the following key configurations:

#### Sidecar
- **Datasources**: Enabled with initialization.
- **Dashboards**: Enabled with default folder `/var/lib/grafana/dashboards`.

#### Ingress
- **Enabled**: Yes
- **Annotations**:
  - Force SSL redirect: `"true"`
  - Proxy body size: `25m`
  - External DNS target: `gw.${domain_wahoo_li:=wahoo.li}`
  - Proxy read/send timeout: `3600s`
  - Custom HTTP errors: `404`
  - Cloudflare proxied: `"false"`
- **Hosts**: `grafana.${domain_wahoo_li:=wahoo.li}`

#### Grafana Configuration
- **Server**:
  - Domain: `grafana.${domain_wahoo_li:=wahoo.li}`
  - Root URL: `https://grafana.${domain_wahoo_li:=wahoo.li}/`
- **Authentication**:
  - OAuth auto-login enabled.
  - Generic OAuth provider: `authentik`.
- **Plugins**:
  - Unsigned plugins allowed: `victoriametrics-datasource`, `victoriametrics-logs-datasource`.

#### Plugins
- VictoriaMetrics Datasource: `v0.10.3`
- VictoriaMetrics Logs Datasource: `v0.13.1`

### ConfigMap: `victoria-metrics-datasource-84792bh299`

This ConfigMap defines multiple datasources for Grafana:
- **VictoriaMetrics-prometheus**: Default datasource for Prometheus metrics.
- **VictoriaMetrics - read-proxy**: Non-default datasource for VictoriaMetrics.
- **VictoriaLogs - distributed**: Non-default datasource for VictoriaLogs.
- **VictoriaLogs - long term**: Non-default datasource for long-term VictoriaLogs.

### Dashboards

A CoreDNS dashboard (`kube-dns-dashboard.json`) is included, providing visualizations for:
- Health status
- CPU usage by instance
- Memory usage by instance
- Total DNS requests
- Average packet size
- Requests by type

## Service Monitoring

A `VMServiceScrape` resource is configured for Grafana:
- **Namespace**: `grafana`
- **Endpoints**: Monitors the `service` port.
- **Selector**: Matches labels:
  - `app.kubernetes.io/instance: grafana`
  - `app.kubernetes.io/name: grafana`

## Summary

Grafana is deployed with robust configurations for monitoring and visualization, including integration with VictoriaMetrics and CoreDNS dashboards. The deployment leverages Flux for GitOps management and Helm for chart installation.
