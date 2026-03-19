---
title: "vector-lb"
parent: "Infrastructure / Logging"
grand_parent: "tpi-1"
---

# vector-lb

The `vector-lb` component is deployed in the `tpi-1` Kubernetes cluster within the `logging` namespace. It is managed using Flux and HelmRelease, leveraging the `vector` Helm chart (version `0.51.0`) from the official Vector Helm repository.

## Overview

`vector-lb` is configured as an Aggregator role, which deploys Vector as a `StatefulSet`. It is designed to collect, process, and route logs efficiently. The deployment is configured to use an existing ConfigMap for its configuration and supports integration with VictoriaMetrics for metrics collection.

---

## Deployment Details

### HelmRelease Configuration

- **Name:** `logging--vector-lb`
- **Namespace:** `flux-system`
- **Chart:** `vector` (version `0.51.0`)
- **Source Repository:** [https://helm.vector.dev](https://helm.vector.dev)
- **Release Name:** `vector-lb`
- **Target Namespace:** `logging`
- **Sync Interval:** 10 minutes
- **Dependencies:** 
  - `victoria-metrics--victoria-metrics-operator` (namespace: `flux-system`)

### Values Configuration

The deployment uses a combination of inline values and external ConfigMaps for configuration:

- **Existing ConfigMaps:**
  - `vector-lb-config-457cm42g2b`
- **Values from ConfigMaps:**
  - `vector-values-5cf8f5678g` (keys: `values-base.yaml`, `values.yaml`)

Key configuration options include:
- **Role:** `Aggregator`
- **Replicas:** `1`
- **Service:**
  - Enabled: `true`
  - Type: `ClusterIP`
- **Pod Annotations:** `vector.dev/exclude: "true"`
- **Persistence:**
  - Enabled: `false`
  - HostPath: `/var/lib/vector`
- **RBAC:** Enabled
- **Service Account:** Automatically created
- **Pod Disruption Budget:** Disabled
- **Autoscaling:** Disabled
- **HAProxy Load Balancer:** Disabled

---

## Kubernetes Resources

The following Kubernetes resources are created by the `vector-lb` HelmRelease:

1. **StatefulSet:** Deploys Vector in Aggregator role.
2. **Service:** Exposes Vector as a `ClusterIP` service.
3. **ConfigMaps:** Used for external configuration (`vector-lb-config-457cm42g2b`, `vector-values-5cf8f5678g`).
4. **ServiceAccount:** Automatically created for the Vector Pods.
5. **HelmRepository:** 
   - Name: `vector`
   - URL: [https://helm.vector.dev](https://helm.vector.dev)
6. **ImageRepository:**
   - Image: `ghcr.io/vectordotdev/helm-charts/vector`
   - Sync Interval: 24 hours
7. **ImagePolicy:**
   - Policy: Semantic versioning (`x.x.x`)

---

## Key Features

- **Log Aggregation:** Configured as an Aggregator to collect and process logs.
- **Custom Configuration:** Supports external ConfigMaps for custom configurations.
- **RBAC Support:** Role-based access control is enabled.
- **Service Exposure:** Exposed as a `ClusterIP` service.
- **Persistence:** HostPath persistence enabled for storing data at `/var/lib/vector`.
- **Pod Annotations:** Custom annotations for Vector Pods.
- **Update Strategy:** Rolling updates for seamless upgrades.

---

## Additional Notes

- The deployment is configured to retry installation indefinitely in case of failures.
- The `vector-lb` component is dependent on the `victoria-metrics--victoria-metrics-operator` for metrics collection.
- The `haproxy` load balancer feature is disabled in this deployment.
- The deployment uses the default Vector image (`timberio/vector`) with the tag derived from the chart's `appVersion`.

For more details on the Vector Helm chart and its configuration options, refer to the [official documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
