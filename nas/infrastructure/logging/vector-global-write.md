---
title: "vector-global-write"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-global-write

## Overview
The `vector-global-write` component is deployed in the `flux-system` namespace of the `nas` cluster. It utilizes the Vector logging tool to aggregate logs across the cluster. This deployment is managed using Flux and Helm.

## Helm Release Details
- **Release Name**: `vector-global-write`
- **Chart**: `vector`
- **Version**: `0.56.0`
- **Target Namespace**: `logging`
- **Update Interval**: 10 minutes
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator` (namespace: `flux-system`)
  - `logging--vector-lb` (namespace: `flux-system`)

## Configuration
The deployment is configured using several ConfigMaps and values defined in the HelmRelease. Key configurations include:

- **Role**: `Aggregator`
- **Replicas**: 1
- **Image**:
  - **Repository**: `timberio/vector`
  - **Pull Policy**: `IfNotPresent`
- **Service**:
  - **Enabled**: true
  - **Type**: `ClusterIP`
- **Headless Service**:
  - **Enabled**: true
- **Log Level**: `info`

### Existing ConfigMaps
The deployment references the following existing ConfigMaps for configuration:
- `vector-global-write-config-bdb5795f69`
- `vector-global-write-values-bct65c9cgf` (contains `values-base.yaml` and `values.yaml`)
- `vector-global-write-helmrelease-overrides` (optional)

### Resource Management
- **Pod Disruption Budget**: Disabled
- **Horizontal Pod Autoscaler**: Disabled
- **Termination Grace Period**: 60 seconds

### Security Context
- **Service Account**: Automatically created with default settings.

## Additional Notes
- The Vector instance is configured to aggregate logs and can be customized further through the provided ConfigMaps.
- Ensure that the dependencies are properly installed and configured for the logging system to function correctly.
