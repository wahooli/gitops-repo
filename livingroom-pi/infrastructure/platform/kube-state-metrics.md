---
title: "kube-state-metrics"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# kube-state-metrics

## Overview
`kube-state-metrics` is a service that listens to the Kubernetes API and generates metrics about the state of the objects. It provides insights into the state of various Kubernetes resources, which can be scraped by Prometheus.

## Deployment Details
- **Release Name:** kube-state-metrics
- **Namespace:** kube-system
- **Helm Chart Version:** 8.0.0
- **Source Repository:** prometheus-community
- **Update Interval:** 10 minutes for the HelmRelease, 24 hours for the ImageRepository

## Dependencies
This deployment depends on the `prometheus-operator--prometheus-operator-crds` resource.

## Configuration
The configuration for `kube-state-metrics` is managed through two ConfigMaps:
1. `kube-state-metrics-values-52k4bbt862` (values-base.yaml)
2. `kube-state-metrics-values-52k4bbt862` (values.yaml)

### Key Configuration Values
- **Prometheus Scrape:** Enabled (`prometheusScrape: true`)
- **Replicas:** 1
- **Service Type:** ClusterIP
- **RBAC:** Enabled with a ClusterRole
- **Service Account:** Created with automounting of API credentials

### Metrics Collection
The following Kubernetes resources are monitored:
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

## Image Details
- **Image Repository:** ghcr.io/prometheus-community/charts/kube-state-metrics
- **Image Policy:** Semver policy is applied for versioning.

## Additional Features
- **Self-Monitoring:** Not enabled by default.
- **Vertical Pod Autoscaler Support:** Not enabled by default.
- **Custom Resource State Metrics:** Enabled with specific configurations for various resource types.

## Security Context
- **Run As User:** 65534
- **Run As Group:** 65534
- **FS Group:** 65534
- **Seccomp Profile:** RuntimeDefault

## Probes
- **Liveness Probe:** Configured to check the health of the service.
- **Readiness Probe:** Configured to ensure the service is ready to accept traffic.

This deployment of `kube-state-metrics` provides essential metrics for monitoring the state of Kubernetes resources, facilitating better observability and management of the cluster.
