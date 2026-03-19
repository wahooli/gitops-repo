---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-agent

The `vector-agent` component is deployed in the `nas` Kubernetes cluster using the Flux CD GitOps framework. It is responsible for log aggregation and processing, and is deployed using the `vector` Helm chart version `0.51.0`.

## Overview

The `vector-agent` is configured as an **Aggregator** role, which means it is deployed as a `StatefulSet` and is responsible for collecting, processing, and forwarding logs. The deployment uses an existing ConfigMap for configuration and is integrated with Flux CD for automated deployment and updates.

---

## Deployment Details

### HelmRelease: `logging--vector-agent`

- **Namespace**: `flux-system`
- **Release Name**: `vector-agent`
- **Target Namespace**: `logging`
- **Chart**: `vector` (version `0.51.0`)
- **Source**: `HelmRepository` named `vector` in the `flux-system` namespace
- **Sync Interval**: 10 minutes
- **Install Remediation**: Unlimited retries (`retries: -1`)
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator` (namespace: `flux-system`)
  - `logging--vector-global-write` (namespace: `flux-system`)

### Configuration

- **Existing ConfigMaps**:
  - `vector-agent-config-kh64622k7t`
- **Values from ConfigMaps**:
  - `vector-agent-values-gm5tgm84t5` (keys: `values-base.yaml`, `values.yaml`)

---

## Image Management

### ImageRepository: `vector-dockerhub`

- **Namespace**: `flux-system`
- **Image**: `timberio/vector`
- **Sync Interval**: 24 hours

### ImagePolicy: `vector-debian`

- **Namespace**: `flux-system`
- **Policy**: Semantic versioning (`x.x.x`)
- **Tag Filter**: Matches tags in the format `MAJOR.MINOR.PATCH-debian`
- **Image Repository Reference**: `vector-dockerhub`

---

## Key Configuration Values

The following key configuration values are applied to the `vector-agent` deployment:

- **Role**: `Aggregator`
- **Replicas**: `1`
- **Image**:
  - Repository: `timberio/vector`
  - Pull Policy: `IfNotPresent`
- **RBAC**:
  - Enabled: `true`
- **Service Account**:
  - Create: `true`
  - Automount Token: `true`
- **Pod Annotations**:
  - `vector.dev/exclude: "true"`
- **Service**:
  - Enabled: `true`
  - Type: `ClusterIP`
- **Headless Service**:
  - Enabled: `true`
- **Persistence**:
  - Enabled: `false`
  - Host Path: `/var/lib/vector`
- **Default Volumes**:
  - `/var/log/` (read-only)
  - `/var/lib` (read-only)
  - `/host/proc` (read-only)
  - `/host/sys` (read-only)
- **Log Level**: `info`

---

## Additional Features

- **Pod Disruption Budget**: Disabled
- **Horizontal Pod Autoscaling**: Disabled
- **Ingress**: Disabled
- **PodMonitor**: Disabled
- **HAProxy Load Balancer**: Disabled

---

## Notes

- The `vector-agent` component is configured to use existing ConfigMaps for its configuration, which overrides the default settings provided by the Helm chart.
- The deployment is integrated with Flux CD for automated reconciliation and updates.
- The `vector-agent` is dependent on the `victoria-metrics--victoria-metrics-operator` and `logging--vector-global-write` components for its operation.

For more details on the Vector Helm chart configuration, refer to the [official documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
