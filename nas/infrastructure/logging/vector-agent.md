---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-agent

The `vector-agent` component is deployed in the `nas` cluster using the Vector Helm chart version `0.52.0`. This component is part of the logging infrastructure and is responsible for collecting and processing logs.

## HelmRelease

### Overview
The `vector-agent` is managed by a `HelmRelease` resource named `logging--vector-agent` in the `flux-system` namespace. It is configured to install the Vector chart from the `flux-system` Helm repository.

### Configuration
- **Release Name**: `vector-agent`
- **Target Namespace**: `logging`
- **Chart Version**: `0.52.0`
- **Update Interval**: 10 minutes
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator`
  - `logging--vector-global-write`

### Values
The following values are configured for the `vector-agent` deployment:
- **Role**: `Aggregator`
- **Replicas**: 1
- **Image**: 
  - Repository: `timberio/vector`
  - Pull Policy: `IfNotPresent`
- **Service**: 
  - Enabled: true
  - Type: `ClusterIP`
- **Existing ConfigMaps**: 
  - `vector-agent-config-926d7t9786`
- **Custom Config**: 
  - Command: `--config-dir /etc/vector/`
  - Args: `--config-dir /etc/vector/`

## Image Repository

### Overview
An `ImageRepository` resource named `vector-dockerhub` is defined to track the Vector image from Docker Hub.

- **Image**: `timberio/vector`
- **Update Interval**: 24 hours

## Image Policy

### Overview
An `ImagePolicy` resource named `vector-debian` is configured to manage the versioning of the Vector image.

- **Filter Tags**: Extracts the version from tags matching the pattern `^(?P<version>[0-9]+\.[0-9]+\.[0-9]+)-debian$`.
- **Policy**: Semantic versioning range is set to `x.x.x`.

## Additional Notes
- The deployment includes configuration for resource requests, limits, and optional features such as autoscaling and pod disruption budgets.
- The Vector agent is designed to run as an aggregator, collecting logs from various sources and forwarding them to configured sinks. 

For more detailed configuration options, refer to the [Vector Helm documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
