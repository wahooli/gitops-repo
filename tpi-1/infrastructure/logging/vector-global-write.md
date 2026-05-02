---
title: "vector-global-write"
parent: "Infrastructure / Logging"
grand_parent: "tpi-1"
---

# vector-global-write

The `vector-global-write` component is deployed in the `flux-system` namespace of the `tpi-1` cluster. It utilizes the Vector logging agent to aggregate logs from various sources.

## HelmRelease Details

- **Name**: `logging--vector-global-write`
- **Namespace**: `flux-system`
- **Chart**: `vector`
- **Version**: `0.52.0`
- **Release Name**: `vector-global-write`
- **Target Namespace**: `logging`
- **Interval**: 10 minutes
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator`
  - `logging--vector-lb`

## Configuration Values

The following configuration values are set for the Vector deployment:

- **Role**: `Aggregator`
- **Replicas**: `1`
- **Image**:
  - **Repository**: `timberio/vector`
  - **Pull Policy**: `IfNotPresent`
  - **Tag**: Derived from the Chart's appVersion
- **Service**:
  - **Enabled**: `true`
  - **Type**: `ClusterIP`
- **Headless Service**:
  - **Enabled**: `true`
- **Existing ConfigMaps**: 
  - `vector-global-write-config-696cmtmf2m`
- **Pod Annotations**:
  - `vector.dev/exclude: "true"`
- **Log Level**: `info`

## Additional Configuration

- **Pod Management Policy**: `OrderedReady`
- **Termination Grace Period**: `60 seconds`
- **DNS Policy**: `ClusterFirst`
- **Service Account**: Created with RBAC enabled.

## Notes

- The Vector instance is configured to run as an Aggregator, which is suitable for collecting logs from multiple sources and sending them to a centralized location.
- The deployment includes a headless service for internal communication between pods.
- Ensure that the dependencies are properly installed and configured for the Vector deployment to function correctly.
