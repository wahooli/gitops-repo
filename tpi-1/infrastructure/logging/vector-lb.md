---
title: "vector-lb"
parent: "Infrastructure / Logging"
grand_parent: "tpi-1"
---

# vector-lb

The `vector-lb` component is deployed in the `logging` namespace of the `tpi-1` cluster using the Vector Helm chart version `0.52.0`. This component is responsible for aggregating logs and metrics from various sources.

## HelmRelease

### Overview
- **Name**: `logging--vector-lb`
- **Namespace**: `flux-system`
- **Release Name**: `vector-lb`
- **Chart Source**: [Vector Helm Repository](https://helm.vector.dev)
- **Chart Version**: `0.52.0`
- **Update Interval**: 10 minutes

### Dependencies
- Depends on `victoria-metrics--victoria-metrics-operator` in the `flux-system` namespace.

### Configuration
The `vector-lb` is configured using the following values:

- **Role**: `Aggregator`
- **Replicas**: 1
- **Service**: Enabled with type `ClusterIP`
- **Existing ConfigMaps**: Uses `vector-lb-config-tct77bkb5g`
- **Pod Annotations**: `vector.dev/exclude: "true"`
- **Log Level**: `info`

### Values from ConfigMaps
The configuration values are sourced from the following ConfigMaps:
- `vector-values-6kt8f5h5hc`:
  - `values-base.yaml`
  - `values.yaml`

## HelmRepository

### Overview
- **Name**: `vector`
- **Namespace**: `flux-system`
- **URL**: `https://helm.vector.dev`
- **Update Interval**: 24 hours

## ImageRepository

### Overview
- **Name**: `vector-helm-chart`
- **Namespace**: `flux-system`
- **Image**: `ghcr.io/vectordotdev/helm-charts/vector`
- **Update Interval**: 24 hours

## ImagePolicy

### Overview
- **Name**: `vector-helm-chart`
- **Namespace**: `flux-system`
- **Policy**: Semantic versioning (semver) range is specified.

## Additional Configuration

### HAProxy
The configuration includes an optional HAProxy load balancer, which is currently disabled. If enabled, it would use the image `haproxytech/haproxy-alpine` with tag `2.6.12`.

### Persistence
Persistence is configured to use hostPath at `/var/lib/vector` for data storage.

### Probes
Liveness and readiness probes can be configured, but defaults are currently set.

### Security Context
The component supports RBAC and can create a ServiceAccount for Vector.

## Notes
- Ensure that the `victoria-metrics--victoria-metrics-operator` is deployed and running before deploying `vector-lb`.
- Review the Vector documentation for detailed configuration options and best practices: [Vector Documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
