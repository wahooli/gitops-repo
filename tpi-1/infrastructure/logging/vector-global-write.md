---
title: "vector-global-write"
parent: "Infrastructure / Logging"
grand_parent: "tpi-1"
---

# vector-global-write

The `vector-global-write` component is a deployment of the [Vector](https://vector.dev/) log aggregation and processing tool in the `tpi-1` Kubernetes cluster. It is managed using Flux and Helm, and is configured to function as an "Aggregator" for log data.

## Helm Chart

- **Chart Name**: `vector`
- **Version**: `0.51.0`
- **Source**: Referenced from a Helm repository named `vector` in the `flux-system` namespace.

## Namespace

- **Target Namespace**: `logging`

## Release Details

- **Release Name**: `vector-global-write`
- **Interval**: 10 minutes
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator` (namespace: `flux-system`)
  - `logging--vector-lb` (namespace: `flux-system`)

## Configuration

### Role

- **Role**: `Aggregator`
  - This role deploys Vector as a `StatefulSet`.

### Image

- **Repository**: `timberio/vector`
- **Pull Policy**: `IfNotPresent`
- **Tag**: Derived from the chart's `appVersion`.

### Replicas

- **Count**: 1

### Configuration Source

The configuration for this deployment is sourced from existing ConfigMaps:
- `vector-global-write-config-dgdtt584kh`
- `vector-global-write-values-mtkcfdk4hm` (keys: `values-base.yaml`, `values.yaml`)
- `vector-global-write-helmrelease-overrides` (optional, key: `values.yaml`)

### Persistence

- **Enabled**: No persistent storage is configured for this deployment.
- **Host Path**: `/var/lib/vector` is used for data storage.

### Autoscaling

- **Enabled**: No autoscaling is configured.

### Service

- **Type**: `ClusterIP`
- **Headless Service**: Enabled

### Security and RBAC

- **RBAC**: Enabled
- **Service Account**: Created with default settings.

### Probes

- **Liveness Probe**: Not explicitly configured.
- **Readiness Probe**: Not explicitly configured.

### Additional Configuration

- **Pod Annotations**: Includes `vector.dev/exclude: "true"`.
- **Pod Priority Class**: Not specified.
- **Node Selector, Tolerations, Affinity**: Not configured.
- **Topology Spread Constraints**: Not configured.

### Logging

- **Log Level**: `info`

### HAProxy Load Balancer

- **Enabled**: No HAProxy load balancer is configured.

## Notes

- The deployment uses existing ConfigMaps for configuration, which takes precedence over the chart's default configurations.
- The `Aggregator` role is suitable for centralized log aggregation and processing.
- For further customization, refer to the [Vector Helm Chart documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).

## Dependencies

Ensure the following dependencies are deployed and healthy before using `vector-global-write`:
- `victoria-metrics--victoria-metrics-operator`
- `logging--vector-lb`

## Troubleshooting

If the deployment is not functioning as expected:
1. Verify the health of the dependent components.
2. Check the logs of the `vector-global-write` pods.
3. Ensure the referenced ConfigMaps are correctly configured and accessible.
