---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# kube-state-metrics

The `kube-state-metrics` component is deployed in the `tpi-1` cluster using the `kube-state-metrics` Helm chart from the `prometheus-community` Helm repository. This component provides Kubernetes cluster state metrics, which are used for monitoring and alerting purposes.

## Deployment Overview

### HelmRelease Configuration

- **Name:** `kube-system--kube-state-metrics`
- **Namespace:** `flux-system`
- **Chart:** `kube-state-metrics`
- **Chart Version:** `7.2.0`
- **Source Repository:** `prometheus-community`
- **Release Name:** `kube-state-metrics`
- **Target Namespace:** `kube-system`
- **Sync Interval:** 10 minutes
- **Dependencies:** 
  - `prometheus-operator--prometheus-operator-crds` (Namespace: `flux-system`)
- **Values Configuration:**
  - Sourced from ConfigMaps:
    - `kube-state-metrics-values-52k4bbt862` (keys: `values-base.yaml`, `values.yaml`)

### Image Automation

- **Image Repository:** `ghcr.io/prometheus-community/charts/kube-state-metrics`
- **Image Update Interval:** 24 hours
- **Image Policy:** Semantic versioning (`x.x.x`)

## Features and Configuration

### General Settings

- **Prometheus Scraping:** Enabled
- **Replicas:** 1
- **RBAC:** Enabled
  - Includes additional rules for Flux-related resources (e.g., `HelmReleases`, `Kustomizations`, `GitRepositories`).
- **Service Type:** `ClusterIP`
  - **Port:** 8080
  - **IP Family Policy:** `PreferDualStack`
- **Service Account:** 
  - Automatically created
  - Automount API credentials: Enabled
- **Pod Security Context:**
  - `runAsUser`: 65534
  - `runAsGroup`: 65534
  - `fsGroup`: 65534
  - `runAsNonRoot`: true
  - `seccompProfile`: `RuntimeDefault`
- **Container Security Context:**
  - `readOnlyRootFilesystem`: true
  - `allowPrivilegeEscalation`: false
  - Dropped capabilities: `ALL`
- **Custom Resource State Metrics:** Enabled
  - Configured to monitor GitOps Toolkit resources (e.g., `Kustomizations`, `HelmReleases`, `GitRepositories`, etc.).

### Monitoring and Metrics

- **Prometheus Monitoring:** Disabled by default
- **Collectors Enabled:**
  - `certificatesigningrequests`, `configmaps`, `cronjobs`, `daemonsets`, `deployments`, `endpoints`, `horizontalpodautoscalers`, `ingresses`, `jobs`, `leases`, `limitranges`, `mutatingwebhookconfigurations`, `namespaces`, `networkpolicies`, `nodes`, `persistentvolumeclaims`, `persistentvolumes`, `poddisruptionbudgets`, `pods`, `replicasets`, `replicationcontrollers`, `resourcequotas`, `secrets`, `services`, `statefulsets`, `storageclasses`, `validatingwebhookconfigurations`, `volumeattachments`
- **Metric Allowlist/Denylist:** Not configured
- **Custom Metrics:** Configured for GitOps Toolkit resources (e.g., `HelmReleases`, `Kustomizations`, `GitRepositories`, etc.).

### Additional Features

- **Auto-sharding:** Disabled
- **Network Policy:** Disabled
- **Pod Disruption Budget:** Not configured
- **Startup, Liveness, and Readiness Probes:** Configured with default values
- **Vertical Pod Autoscaler:** Disabled
- **Kube-RBAC-Proxy:** Disabled
- **Custom Volumes and Volume Mounts:** Not configured

## Dependencies

This component depends on the `prometheus-operator-crds` HelmRelease in the `flux-system` namespace.

## Notes

- The `kube-state-metrics` chart version is pinned to `7.2.0`.
- The component is configured to scrape metrics for Prometheus by default.
- The deployment is configured to run with a single replica and uses a `ClusterIP` service type.
- Additional RBAC rules are configured to monitor Flux-related resources.
- Custom resource state metrics are enabled for GitOps Toolkit resources, providing detailed insights into their state.

For more details on the `kube-state-metrics` Helm chart, refer to the [official documentation](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics).
