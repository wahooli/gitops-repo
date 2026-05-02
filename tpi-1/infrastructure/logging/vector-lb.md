---
title: "vector-lb"
parent: "Infrastructure / Logging"
grand_parent: "tpi-1"
---

# vector-lb

The `vector-lb` component is deployed in the `logging` namespace of the `tpi-1` cluster using the Vector Helm chart version `0.52.0`. This component is responsible for aggregating logs and metrics from various sources and providing a unified logging solution.

## HelmRelease Configuration

### General Information
- **Release Name**: `vector-lb`
- **Namespace**: `flux-system`
- **Chart Source**: [Vector Helm Repository](https://helm.vector.dev)
- **Chart Version**: `0.52.0`
- **Update Interval**: 10 minutes

### Dependencies
- The `vector-lb` HelmRelease depends on the `victoria-metrics--victoria-metrics-operator` in the `flux-system` namespace.

### Values Configuration
The following values are configured for the `vector-lb` deployment:

- **Role**: `Aggregator`
- **Replicas**: 1
- **Service Configuration**:
  - **Enabled**: true
  - **Type**: `ClusterIP`
- **Existing ConfigMaps**: 
  - `vector-lb-config-tct77bkb5g`
- **Image Configuration**:
  - **Repository**: `timberio/vector`
  - **Pull Policy**: `IfNotPresent`
- **Logging Level**: `info`
- **Pod Security Context**: Custom security settings can be applied.

### ConfigMaps Used
- **Base Values**: Configurations are sourced from `vector-values-5cf8f5678g` ConfigMap, specifically from `values-base.yaml` and `values.yaml`.

## Additional Resources
- **Image Repository**: The images for the Vector component are sourced from `ghcr.io/vectordotdev/helm-charts/vector`.
- **Image Policy**: The image policy is set to allow semantic versioning.

## Notes
- The deployment includes configurations for logging, metrics aggregation, and potential integration with other services.
- Ensure that the `victoria-metrics--victoria-metrics-operator` is properly deployed and configured, as it is a prerequisite for the `vector-lb` component to function correctly.
