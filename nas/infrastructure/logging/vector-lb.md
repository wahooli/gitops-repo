---
title: "vector-lb"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-lb

The `vector-lb` component is deployed in the `logging` namespace of the `nas` cluster using the Vector Helm chart version `0.52.0`. This deployment is part of the infrastructure logging setup and is managed by Flux.

## HelmRelease Configuration

### General Information
- **Release Name**: `vector-lb`
- **Namespace**: `flux-system`
- **Chart Source**: [Vector Helm Repository](https://helm.vector.dev)
- **Chart Version**: `0.52.0`
- **Update Interval**: `10m`
- **Dependencies**: This release depends on the `victoria-metrics--victoria-metrics-operator`.

### Values Configuration
The following values are configured for the `vector-lb` deployment:

- **Role**: `Aggregator`
- **Replicas**: `1`
- **Service Configuration**:
  - **Enabled**: `true`
  - **Type**: `ClusterIP`
- **Existing ConfigMaps**: 
  - `vector-lb-config-5g2tbdbbht`
- **Custom Values**: Loaded from the `vector-values-45cgt64k58` ConfigMap, which includes:
  - **Log Level**: `info`
  - **Termination Grace Period**: `60 seconds`
  - **Pod Disruption Budget**: Disabled
  - **RBAC**: Enabled
  - **Service Account**: Created

### Additional Features
- **HAProxy**: The built-in HAProxy load balancer is disabled by default.
- **Autoscaling**: Disabled.
- **PodMonitor**: Not enabled.

## Resources Created
The `vector-lb` HelmRelease will create the following Kubernetes resources:
- A StatefulSet for the Vector Aggregator.
- A Service for internal communication.
- ConfigMaps for configuration management.

## Monitoring and Logging
Vector is configured to log at the `info` level, and it can be monitored using Prometheus if the PodMonitor is enabled.

## Notes
- Ensure that the `victoria-metrics--victoria-metrics-operator` is deployed and available before deploying `vector-lb`.
- For detailed configuration options, refer to the [Vector Helm documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
