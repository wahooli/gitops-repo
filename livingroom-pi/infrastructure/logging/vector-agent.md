---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "livingroom-pi"
---

# vector-agent

The `vector-agent` component is deployed in the `livingroom-pi` cluster using the Vector Helm chart version `0.52.0`. This component is responsible for collecting and processing logs and metrics from the cluster.

## Overview

The deployment consists of a HelmRelease that manages the installation of the Vector agent, along with associated ConfigMaps and image repositories for the required images.

### HelmRelease

- **Name**: `logging--vector-agent`
- **Namespace**: `flux-system`
- **Release Name**: `vector-agent`
- **Target Namespace**: `logging`
- **Chart Source**: [Vector Helm Repository](https://helm.vector.dev)
- **Chart Version**: `0.52.0`
- **Update Interval**: 10 minutes

### Dependencies

The `vector-agent` depends on the following component:
- `victoria-metrics--victoria-metrics-operator` (Namespace: `flux-system`)

### Configuration

The Vector agent is configured using the following values:

- **Role**: `Aggregator`
- **Replicas**: `1`
- **Service**: Enabled with type `ClusterIP`
- **Existing ConfigMaps**: 
  - `vector-agent-config-tc927k88m7`
- **Values from ConfigMaps**:
  - `vector-agent-values-tc42b2k4fg` (keys: `values-base.yaml`, `values.yaml`)

### Image Repositories

The deployment uses the following image repositories:
1. **Vector Helm Chart**:
   - **Image**: `ghcr.io/vectordotdev/helm-charts/vector`
   - **Update Interval**: 24 hours

2. **Vector Docker Hub**:
   - **Image**: `timberio/vector`
   - **Update Interval**: 24 hours

### Image Policies

Image policies are defined to manage the versions of the images used:
- **Vector Helm Chart**: Policy for semantic versioning.
- **Vector Debian**: Filters tags for specific version patterns.

### Additional Configuration

The configuration for the Vector agent includes:
- **Log Level**: `info`
- **Pod Disruption Budget**: Disabled
- **RBAC**: Enabled
- **Service Account**: Created with default settings
- **Termination Grace Period**: 60 seconds

### Notes

- The Vector agent is designed to run as an aggregator, collecting logs and metrics from various sources within the Kubernetes cluster.
- Ensure that the ConfigMaps referenced in the deployment are correctly configured to avoid issues during startup.

For more detailed information on configuring and using Vector, refer to the [Vector documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
