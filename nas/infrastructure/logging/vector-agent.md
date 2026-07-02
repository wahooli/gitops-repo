---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-agent

The `vector-agent` component is deployed in the `nas` cluster to handle logging and data collection. It utilizes the Vector tool, which is designed for high-performance data processing and routing.

## Deployment Details

### HelmRelease

- **Name**: `logging--vector-agent`
- **Namespace**: `flux-system`
- **Chart Version**: `0.56.0`
- **Release Name**: `vector-agent`
- **Target Namespace**: `logging`
- **Update Interval**: 10 minutes
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator`
  - `logging--vector-global-write`

### Configuration

The deployment uses the following configuration values:

- **Role**: `Aggregator`
- **Replicas**: 1
- **Image**: `timberio/vector`
- **Image Pull Policy**: `IfNotPresent`
- **Service**: Enabled with type `ClusterIP`
- **Headless Service**: Enabled
- **Existing ConfigMaps**: 
  - `vector-agent-config-926d7t9786`
- **Custom Configurations**: 
  - Uses values from `vector-agent-values-cbdkf978bd` ConfigMap.

### Image Repository

- **Image Repository**: `timberio/vector`
- **Image Policy**: 
  - Filter Tags: `^([0-9]+\.[0-9]+\.[0-9]+)-debian$`
  - Semver Range: `x.x.x`

### Resource Management

- **Pod Management Policy**: `OrderedReady`
- **Termination Grace Period**: 60 seconds
- **Pod Security Context**: Customizable
- **Service Account**: Created for Vector

### Probes

- **Liveness Probe**: Customizable
- **Readiness Probe**: Customizable

### Logging Level

- **Log Level**: `info`

### Additional Features

- **Pod Disruption Budget**: Disabled
- **Horizontal Pod Autoscaler**: Disabled
- **Persistence**: 
  - HostPath enabled with path `/var/lib/vector`
  
### Notes

- Ensure that the necessary ConfigMaps and dependencies are in place for the `vector-agent` to function correctly.
- Review the Vector documentation for further customization and configuration options: [Vector Documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
