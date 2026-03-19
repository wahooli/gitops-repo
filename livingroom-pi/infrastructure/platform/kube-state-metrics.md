---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# kube-state-metrics

The `kube-state-metrics` component is deployed in the `livingroom-pi` cluster to provide detailed metrics about the state of Kubernetes objects. These metrics are designed to be consumed by Prometheus or other monitoring systems to provide insights into the health and status of the cluster.

## Overview

- **Chart Name**: `kube-state-metrics`
- **Chart Version**: `7.2.0`
- **Source Repository**: [prometheus-community](https://github.com/prometheus-community/helm-charts)
- **Namespace**: `kube-system`
- **Release Name**: `kube-state-metrics`

This deployment is managed using Flux's HelmRelease and integrates with Prometheus for monitoring.

---

## Deployment Details

### HelmRelease Configuration

- **Chart Source**: The Helm chart is sourced from the `prometheus-community` Helm repository.
- **Values Configuration**: The deployment uses values from two ConfigMaps:
  - `kube-state-metrics-values-52k4bbt862` (keys: `values-base.yaml`, `values.yaml`).
- **Dependencies**: The deployment depends on the `prometheus-operator-crds` HelmRelease in the `flux-system` namespace.
- **Update Interval**: The HelmRelease is reconciled every 10 minutes.
- **Remediation**: Unlimited retries are configured for installation remediation.

### Image Management

- **Image Repository**: `ghcr.io/prometheus-community/charts/kube-state-metrics`
- **Image Update Policy**: Managed by Flux's ImagePolicy with a semantic versioning range (`x.x.x`).
- **Image Pull Interval**: Every 24 hours.

---

## Key Features and Configuration

### Metrics Collection

- **Prometheus Scraping**: Enabled by default (`prometheusScrape: true`).
- **Collectors**: The following Kubernetes resources are monitored:
  - Certificatesigningrequests, Configmaps, Cronjobs, Daemonsets, Deployments, Endpoints, Horizontalpodautoscalers, Ingresses, Jobs, Leases, Limitranges, Mutatingwebhookconfigurations, Namespaces, Networkpolicies, Nodes, Persistentvolumeclaims, Persistentvolumes, Poddisruptionbudgets, Pods, Replicasets, Replicationcontrollers, Resourcequotas, Secrets, Services, Statefulsets, Storageclasses, Validatingwebhookconfigurations, Volumeattachments.

### RBAC

- **RBAC Enabled**: Yes, with a ClusterRole by default (`rbac.create: true`, `rbac.useClusterRole: true`).
- **Additional Rules**: Custom RBAC rules are defined to monitor Flux resources (e.g., HelmReleases, Kustomizations, GitRepositories).

### Deployment Configuration

- **Replicas**: 1 (default).
- **Service Type**: ClusterIP (default port: 8080).
- **Security Context**: Configured for non-root execution:
  - `runAsUser: 65534`
  - `runAsGroup: 65534`
  - `fsGroup: 65534`
  - `readOnlyRootFilesystem: true`

### Custom Resource State Metrics

- **Enabled**: Yes (`customResourceState.enabled: true`).
- **Monitored Resources**: Includes Flux resources such as `Kustomization`, `HelmRelease`, `GitRepository`, `Bucket`, `HelmRepository`, and `HelmChart`.
- **Metrics**: Custom metrics are defined for each resource, including labels for namespace, readiness, suspension, and revision.

### Networking

- **Host Network**: Disabled (`hostNetwork: false`).
- **Network Policy**: Disabled by default.

### Resource Management

- **Resource Requests and Limits**: Not specified by default, allowing flexibility for different environments.

---

## Monitoring Integration

- **Prometheus Operator**: The deployment integrates with Prometheus via a ServiceMonitor (if enabled).
- **Self-Monitoring**: Disabled by default (`selfMonitor.enabled: false`).

---

## Additional Features

- **Auto-sharding**: Disabled by default (`autosharding.enabled: false`).
- **Vertical Pod Autoscaler**: Disabled by default.
- **Pod Security Policy**: Not enabled.
- **Startup, Liveness, and Readiness Probes**: Configured with default values for health checks.

---

## Notes

- This deployment is managed by Flux and adheres to GitOps principles.
- The HelmRelease is configured to automatically reconcile and update the deployment based on the specified chart version and values.
- For further customization, update the `values-base.yaml` and `values.yaml` ConfigMaps in the `flux-system` namespace.
