---
title: "vector-lb"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-lb

The `vector-lb` component is a deployment of the [Vector](https://vector.dev/) observability tool in the `nas` cluster. It is managed using Flux and Helm, with the `vector` Helm chart sourced from the official Vector Helm repository.

## Overview

- **Namespace**: `logging`
- **Helm Chart**: `vector` (version `0.51.0`)
- **Source Repository**: [https://helm.vector.dev](https://helm.vector.dev)
- **Release Name**: `vector-lb`
- **Role**: Aggregator (deployed as a StatefulSet)
- **Dependencies**: `victoria-metrics--victoria-metrics-operator`

## Configuration

### Chart Values

The deployment uses a combination of directly specified values and values sourced from ConfigMaps:

1. **Directly Specified Values**:
   - `existingConfigMaps`: `vector-lb-config-8558hkbbm6`

2. **Values from ConfigMaps**:
   - ConfigMap: `vector-values-45cgt64k58`
     - Key: `values-base.yaml`
     - Key: `values.yaml`

### Key Configuration Details

- **Image**:
  - Repository: `timberio/vector`
  - Pull Policy: `IfNotPresent`
  - Tag: Derived from the chart's `appVersion`.

- **Replicas**: 1 (default for Aggregator role)
- **Pod Management Policy**: `OrderedReady`
- **Service**:
  - Type: `ClusterIP`
  - Headless Service: Enabled
- **Persistence**:
  - Enabled: No
  - HostPath: `/var/lib/vector`
- **RBAC**: Enabled
- **Service Account**:
  - Created: Yes
  - Automount Token: Yes
- **Pod Annotations**:
  - `vector.dev/exclude`: `"true"`
- **Pod Security Context**: Default
- **Liveness and Readiness Probes**: Not explicitly configured
- **Autoscaling**: Disabled
- **Pod Disruption Budget**: Disabled
- **HAProxy Load Balancer**: Disabled

### Default Volumes and Mounts

- **Volumes**:
  - `/var/log/` (read-only)
  - `/var/lib` (read-only)
  - `/proc` (read-only)
  - `/sys` (read-only)
- **Volume Mounts**:
  - `/var/log/`
  - `/var/lib`
  - `/host/proc`
  - `/host/sys`

## Image Automation

The deployment uses Flux's image automation capabilities:

- **Image Repository**: `ghcr.io/vectordotdev/helm-charts/vector`
- **Image Policy**: Semantic versioning (`x.x.x`)

## Additional Notes

- The `vector-lb` deployment is configured to use an external configuration provided via the `vector-lb-config-8558hkbbm6` ConfigMap.
- The deployment is dependent on the `victoria-metrics--victoria-metrics-operator` HelmRelease, which must be deployed and available in the `flux-system` namespace.
- The `vector` Helm chart is configured to fetch updates every 24 hours, and the HelmRelease is reconciled every 10 minutes.
- The deployment does not currently use an Ingress or PodMonitor.

For more details on the Vector Helm chart and its configuration options, refer to the [official documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
