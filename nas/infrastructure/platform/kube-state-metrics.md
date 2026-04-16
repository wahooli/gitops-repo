---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kube-state-metrics

The `kube-state-metrics` component is deployed in the `kube-system` namespace of the `nas` cluster using Flux CD. This component provides metrics about the state of Kubernetes objects, which can be scraped by Prometheus.

## Deployment Details

- **Helm Chart**: `kube-state-metrics`
- **Version**: 7.2.2
- **Helm Repository**: `prometheus-community`
- **Release Name**: `kube-state-metrics`
- **Target Namespace**: `kube-system`
- **Update Interval**: 10 minutes
- **Dependencies**: 
  - `prometheus-operator--prometheus-operator-crds`

## Configuration

The deployment is configured using values from two ConfigMaps:
- `kube-state-metrics-values-52k4bbt862` with keys:
  - `values-base.yaml`
  - `values.yaml`

### Key Configuration Options

- **Prometheus Scrape**: Enabled (`prometheusScrape: true`)
- **Replicas**: 1
- **Service Type**: ClusterIP
- **RBAC**: Enabled with a ClusterRole
- **Service Account**: Created with automounting of API credentials enabled

### Metrics Collection

The following Kubernetes resources are collected by `kube-state-metrics`:
- Certificatesigningrequests
- Configmaps
- Cronjobs
- Daemonsets
- Deployments
- Endpoints
- Horizontalpodautoscalers
- Ingresses
- Jobs
- Leases
- Limitranges
- Mutatingwebhookconfigurations
- Namespaces
- Networkpolicies
- Nodes
- Persistentvolumeclaims
- Persistentvolumes
- Poddisruptionbudgets
- Pods
- Replicasets
- Replicationcontrollers
- Resourcequotas
- Secrets
- Services
- Statefulsets
- Storageclasses
- Validatingwebhookconfigurations
- Volumeattachments

## Image Repository

- **Image**: `ghcr.io/prometheus-community/charts/kube-state-metrics`
- **Image Policy**: Set to track semantic versioning.

## Additional Notes

- The deployment includes configurations for security contexts, probes (liveness, readiness), and resource limits.
- Custom metrics can be configured through the `customResourceState` settings.
- The deployment supports vertical pod autoscaling, though it is currently disabled.

This documentation provides a comprehensive overview of the `kube-state-metrics` deployment, its configuration, and its operational parameters within the Kubernetes cluster.
