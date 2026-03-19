---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "livingroom-pi"
---

# Vector Agent

The `vector-agent` component is deployed in the `livingroom-pi` cluster to manage logging infrastructure using the Vector Helm chart. It is configured as an aggregator to collect and process logs.

## Deployment Overview

### HelmRelease Configuration
- **Name**: `logging--vector-agent`
- **Namespace**: `flux-system`
- **Target Namespace**: `logging`
- **Chart**: `vector`
- **Version**: `0.51.0`
- **Source Repository**: [https://helm.vector.dev](https://helm.vector.dev)
- **Release Name**: `vector-agent`
- **Update Interval**: 10 minutes
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator` (Namespace: `flux-system`)

### Values Configuration
The deployment uses custom values provided via two ConfigMaps:
- `vector-agent-values-kth4kf668g`:
  - `values-base.yaml`: Default values for Vector configuration.
  - `values.yaml`: Additional custom values.
- `existingConfigMaps`: `vector-agent-config-tc927k88m7`

### Key Configuration Parameters
- **Role**: Aggregator
  - Deploys as a StatefulSet.
- **Image**:
  - Repository: `timberio/vector`
  - Pull Policy: `IfNotPresent`
- **Replicas**: 1
- **Service**:
  - Enabled: `true`
  - Type: `ClusterIP`
- **Headless Service**:
  - Enabled: `true`
- **Pod Disruption Budget**:
  - Enabled: `false`
- **RBAC**:
  - Enabled: `true`
- **Persistence**:
  - HostPath persistence enabled at `/var/lib/vector`
- **Pod Labels**:
  - `vector.dev/exclude: "true"`
- **Log Level**: `info`

### Image Management
The following ImageRepository and ImagePolicy resources are defined for managing Vector images:
1. **ImageRepository**: `vector-helm-chart`
   - Repository: `ghcr.io/vectordotdev/helm-charts/vector`
   - Update Interval: 24 hours
2. **ImagePolicy**: `vector-helm-chart`
   - Policy: SemVer range `x.x.x`
3. **ImageRepository**: `vector-dockerhub`
   - Repository: `timberio/vector`
   - Update Interval: 24 hours
4. **ImagePolicy**: `vector-debian`
   - Filter Tags: Extract version matching `^([0-9]+\.[0-9]+\.[0-9]+)-debian$`
   - Policy: SemVer range `x.x.x`

### Configuration Details
The deployment uses existing ConfigMaps for configuration:
- `vector-agent-config-tc927k88m7`: Contains configuration files for Vector.
- `vector-agent-values-kth4kf668g`: Provides base and additional values.

#### Key Features
- **RBAC**: Role-based access control is enabled.
- **ServiceAccount**: Automatically created for Vector.
- **Pod Security Context**: Configurable for enhanced security.
- **Affinity and Tolerations**: Customizable for scheduling.
- **Autoscaling**: Disabled by default.
- **PodMonitor**: Not enabled.

### Default Volumes and Mounts
The following volumes and mounts are configured:
- **Volumes**:
  - `/var/log/` (read-only)
  - `/var/lib/` (read-only)
  - `/proc` (read-only)
  - `/sys` (read-only)
- **Mounts**:
  - `/var/log/`
  - `/var/lib`
  - `/host/proc`
  - `/host/sys`

### Additional Configuration
- **Termination Grace Period**: 60 seconds.
- **DNS Policy**: `ClusterFirst`.
- **Ingress**: Disabled.

## References
- [Vector Helm Chart Documentation](https://vector.dev/docs/setup/installation/package-managers/helm/)
- [Vector Configuration Documentation](https://vector.dev/docs/reference/configuration/)
