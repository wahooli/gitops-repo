---
title: "alerting"
parent: "Infrastructure / Alerting"
grand_parent: "nas"
---

# Alerting

The `alerting` component in the `nas` cluster is responsible for managing alerting configurations, routing, and rules for monitoring system and application health. It integrates with VictoriaMetrics and Prometheus Alertmanager for alerting and notification purposes.

## Namespace

The `alerting` component operates within the `alerting` namespace.

## HTTP Routes

The following HTTP routes are configured for external access:

- **Alertmanager**  
  - Hostname: `alertmanager.absolutist.it`
  - Backend: `vmalertmanager-nas` on port `9093`

- **VMAlert Logs**  
  - Hostname: `log-alerts.absolutist.it`
  - Backend: `vmalert-vlogs-nas` on port `8080`

- **VMAlert Metrics**  
  - Hostname: `metrics-alerts.absolutist.it`
  - Backend: `vmalert-vmetrics-nas` on port `8080`

## Services

- **vmalertmanager-tpi-1**  
  - Type: `ClusterIP`
  - Ports:
    - HTTP: `9093`
    - TCP Mesh: `9094`
    - UDP Mesh: `9094`

## Image Management

### VictoriaMetrics VMAlert

- **Image Repository**: `victoriametrics/vmalert`
- **Update Interval**: `24h`
- **Image Policy**: Semantic versioning (`x.x.x`)

### Prometheus Alertmanager

- **Image Repository**: `prom/alertmanager`
- **Update Interval**: `24h`
- **Image Policy**: Semantic versioning (`x.x.x`)

## Alerting Rules

### Smartctl Rules

Alerts for monitoring device health using Smartctl metrics:

- **SmartDeviceTemperatureWarning**: Triggered when device temperature exceeds 60°C for 2 minutes.
- **SmartDeviceTemperatureCritical**: Triggered when device temperature exceeds 80°C for 2 minutes.
- **SmartCriticalWarning**: Triggered when a device reports critical warnings for 15 minutes.
- **SmartMediaErrors**: Triggered when media errors are detected for 15 minutes.
- **SmartNvmeWearoutIndicator**: Triggered when NVMe devices approach wear-out thresholds for 15 minutes.

### Kubernetes Applications

Alerts for monitoring Kubernetes application health:

- **KubePodCrashLooping**: Detects pods in a crash loop state.
- **KubePodNotReady**: Detects pods in a non-ready state for over 15 minutes.
- **KubeDeploymentGenerationMismatch**: Detects mismatched deployment generations.
- **KubeDeploymentReplicasMismatch**: Detects mismatched deployment replicas.
- **KubeDeploymentRolloutStuck**: Detects deployment rollouts that are not progressing.
- **KubeStatefulSetReplicasMismatch**: Detects mismatched StatefulSet replicas.
- **KubeStatefulSetGenerationMismatch**: Detects mismatched StatefulSet generations.
- **KubeStatefulSetUpdateNotRolledOut**: Detects unrolled updates in StatefulSets.
- **KubeDaemonSetRolloutStuck**: Detects stuck DaemonSet rollouts.
- **KubeContainerWaiting**: Detects containers in waiting state for over 1 hour.
- **KubeDaemonSetNotScheduled**: Detects unscheduled DaemonSet pods.
- **KubeDaemonSetMisScheduled**: Detects DaemonSet pods running on incorrect nodes.
- **KubeJobNotCompleted**: Detects jobs taking longer than 12 hours to complete.
- **KubeJobFailed**: Detects failed jobs.
- **KubeHpaReplicasMismatch**: Detects mismatched HPA replicas.
- **KubeHpaMaxedOut**: Detects HPA running at maximum replicas for over 15 minutes.

### Kubernetes Resources

Alerts for monitoring Kubernetes resource utilization:

- **KubeCPUOvercommit**: Detects overcommitted CPU resource requests.
- **KubeMemoryOvercommit**: Detects overcommitted memory resource requests.
- **KubeCPUQuotaOvercommit**: Detects overcommitted CPU quotas for namespaces.
- **KubeMemoryQuotaOvercommit**: Detects overcommitted memory quotas for namespaces.
- **KubeQuotaAlmostFull**: Detects namespaces nearing quota limits.

## Alertmanager Configurations

### Generic Alerts

- **Receiver**: Discord
- **Route**:
  - Group by: `alertgroup`, `alertname`
  - Group interval: `5m`
  - Group wait: `0s`
  - Repeat interval: `3h`
  - Routes:
    - Alerts with `alertname="SomeRemoteWriteTargetsFailing"` are routed to Discord with a repeat interval of `24h`.

### Systemd Alerts

- **Receiver**: Discord
- **Route**:
  - Group by: `systemd_host`, `systemd_unit`
  - Group interval: `15m`
  - Group wait: `120s`
  - Repeat interval: `6h`
  - Matchers: Alerts originating from `journald` sources.

## ConfigMap Templates

Custom Grafana URL templates for logs and metrics exploration:

- **Logs URL**: Configured for VictoriaMetrics logs datasource.
- **Metrics URL**: Configured for Prometheus metrics datasource.

## External DNS Configuration

External DNS annotations are set for the HTTP routes to enable DNS resolution for the following domains:

- `alertmanager.absolutist.it`
- `log-alerts.absolutist.it`
- `metrics-alerts.absolutist.it`

## Summary

The `alerting` component provides comprehensive monitoring and alerting capabilities for the `nas` cluster, including system health, Kubernetes resource utilization, and application monitoring. It integrates with VictoriaMetrics and Prometheus Alertmanager, and supports external notifications via Discord.
