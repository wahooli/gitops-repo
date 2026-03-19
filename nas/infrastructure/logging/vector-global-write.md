---
title: "vector-global-write"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-global-write

The `vector-global-write` component is a deployment of the [Vector](https://vector.dev/) log aggregation tool in the `nas` Kubernetes cluster. It is managed using Flux's HelmRelease and is configured to act as an "Aggregator" for log data.

## Helm Chart Details

- **Chart Name**: `vector`
- **Chart Version**: `0.51.0`
- **Source Repository**: Referenced via a HelmRepository named `vector` in the `flux-system` namespace.
- **Release Name**: `vector-global-write`
- **Target Namespace**: `logging`

## Dependencies

This HelmRelease depends on the following components:
- `victoria-metrics--victoria-metrics-operator` in the `flux-system` namespace.
- `logging--vector-lb` in the `flux-system` namespace.

## Configuration

### Role
- **Role**: `Aggregator`  
  The deployment is configured as an "Aggregator," which uses a StatefulSet to manage pods.

### Image
- **Repository**: `timberio/vector`
- **Pull Policy**: `IfNotPresent`
- **Tag**: Not explicitly set (defaults to the chart's appVersion).

### Replicas
- **Number of Replicas**: 1

### Service
- **Type**: `ClusterIP`
- **Headless Service**: Enabled

### Persistence
- **Enabled**: No persistent volume claims are created.
- **Host Path**: `/var/lib/vector` is used for hostPath persistence.

### Configuration Management
- **Existing ConfigMaps**: 
  - `vector-global-write-config-4mm2g6t2cf`
- **Additional Values from ConfigMaps**:
  - `vector-global-write-values-bct65c9cgf` (keys: `values-base.yaml`, `values.yaml`)
  - `vector-global-write-helmrelease-overrides` (optional, key: `values.yaml`)

### Resource Management
- **Resource Requests and Limits**: Not explicitly defined.

### Autoscaling
- **Enabled**: No autoscaling is configured.

### Security
- **RBAC**: Enabled
- **Pod Security Policy**: Not created (deprecated in Kubernetes v1.21+).

### Probes
- **Liveness Probe**: Not explicitly configured.
- **Readiness Probe**: Not explicitly configured.

### Logging
- **Log Level**: `info`

### Additional Features
- **Pod Disruption Budget**: Not enabled.
- **HAProxy Load Balancer**: Not enabled.

## Annotations and Labels

### Annotations
- **Base HelmRelease**: `vector`

### Labels
- **Kustomize Name**: `infrastructure-logging`
- **Kustomize Namespace**: `flux-system`

## Update and Remediation Strategy

- **Install Remediation**: Unlimited retries on failure.
- **Update Interval**: Every 10 minutes.
- **Chart Update Interval**: Every 24 hours.

## Additional Notes

- The deployment uses a combination of default and custom configurations for Vector, as defined in the `values-base.yaml` and `values.yaml` files.
- The deployment includes default volume mounts for `/var/log/`, `/var/lib/`, `/proc`, and `/sys`.
- The StatefulSet uses an `OrderedReady` pod management policy.
- The deployment does not include an Ingress resource by default.

For more details on the Vector Helm chart configuration, refer to the [official documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
