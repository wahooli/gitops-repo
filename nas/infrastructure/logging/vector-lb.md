---
title: "vector-lb"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-lb

The `vector-lb` component is deployed in the `logging` namespace of the `nas` cluster using the Vector Helm chart version `0.57.0`. This component is responsible for aggregating logs and metrics from various sources.

## HelmRelease

### Metadata
- **Name:** `logging--vector-lb`
- **Namespace:** `flux-system`
- **Release Name:** `vector-lb`
- **Chart Source:** [Vector Helm Repository](https://helm.vector.dev)
- **Chart Version:** `0.57.0`
- **Interval:** 10 minutes

### Dependencies
- **Depends On:** `victoria-metrics--victoria-metrics-operator` in the `flux-system` namespace.

### Values Configuration
The following values are configured for the Vector deployment:

- **Role:** `Aggregator`
- **Replicas:** `1`
- **Service Configuration:**
  - **Enabled:** `true`
  - **Type:** `ClusterIP`
- **Existing ConfigMaps:** 
  - `vector-lb-config-5g2tbdbbht`
- **Values from ConfigMaps:**
  - `vector-values-45cgt64k58` (keys: `values-base.yaml`, `values.yaml`)

### Additional Configuration
- **Pod Management Policy:** `OrderedReady`
- **Termination Grace Period:** `60 seconds`
- **Log Level:** `info`
- **Pod Security Context:** Customizable
- **Service Account:** Created for Vector Pods

## HelmRepository

### Metadata
- **Name:** `vector`
- **Namespace:** `flux-system`
- **URL:** `https://helm.vector.dev`
- **Interval:** 24 hours

## Image Repository

### Metadata
- **Name:** `vector-helm-chart`
- **Namespace:** `flux-system`
- **Image:** `ghcr.io/vectordotdev/helm-charts/vector`
- **Interval:** 24 hours

## Image Policy

### Metadata
- **Name:** `vector-helm-chart`
- **Namespace:** `flux-system`
- **Policy:** Semantic versioning range specified as `x.x.x`.

## Configuration Overview
The Vector deployment is configured to aggregate logs and metrics, with the following key configurations:
- **Service:** Exposes Vector as a ClusterIP service.
- **Pod Disruption Budget:** Disabled.
- **Horizontal Pod Autoscaler:** Not enabled.
- **Persistence:** Not enabled by default, but can be configured to use hostPath.

For detailed configuration options, refer to the [Vector Helm documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
