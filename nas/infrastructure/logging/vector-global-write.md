---
title: "vector-global-write"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-global-write

The `vector-global-write` component is deployed in the `flux-system` namespace of the `nas` cluster. It utilizes the Vector logging agent to aggregate logs and metrics from various sources.

## Helm Release Details

- **Release Name**: `vector-global-write`
- **Chart**: `vector`
- **Chart Version**: `0.57.0`
- **Namespace**: `flux-system`
- **Target Namespace**: `logging`
- **Update Interval**: 10 minutes
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator`
  - `logging--vector-lb`

## Configuration

The deployment is configured using values from existing ConfigMaps and specific values defined in the HelmRelease. Key configurations include:

- **Role**: `Aggregator`
- **Replicas**: 1
- **Image**: `timberio/vector`
- **Service**: Enabled with type `ClusterIP`
- **Headless Service**: Enabled
- **Log Level**: `info`

### ConfigMaps Used

1. **Base Values**: `vector-global-write-values-bct65c9cgf` (key: `values-base.yaml`)
2. **Custom Values**: `vector-global-write-values-bct65c9cgf` (key: `values.yaml`)
3. **Overrides**: `vector-global-write-helmrelease-overrides` (optional, key: `values.yaml`)

### Important Configuration Options

- **Existing ConfigMaps**: 
  - `vector-global-write-config-bdb5795f69`
- **Pod Management Policy**: `OrderedReady`
- **Termination Grace Period**: 60 seconds
- **Service Account**: Created for Vector

## Additional Features

- **Pod Disruption Budget**: Disabled
- **Horizontal Pod Autoscaler**: Disabled
- **RBAC**: Enabled
- **PodMonitor**: Disabled

This deployment is designed to efficiently collect and process logs and metrics, ensuring high availability and scalability within the logging namespace. For more detailed configuration options, refer to the [Vector Helm documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
