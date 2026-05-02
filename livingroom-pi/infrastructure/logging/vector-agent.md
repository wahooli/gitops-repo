---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "livingroom-pi"
---

# vector-agent

The `vector-agent` component is deployed in the `livingroom-pi` cluster using Flux and Helm. It is responsible for collecting and processing logs and metrics from various sources.

## Overview

- **Helm Chart**: `vector`
- **Version**: `0.52.0`
- **Release Name**: `vector-agent`
- **Namespace**: `logging`
- **Dependencies**: Depends on `victoria-metrics--victoria-metrics-operator` in the `flux-system` namespace.

## Configuration

The `vector-agent` is configured through a combination of Helm values and existing ConfigMaps. The key configurations include:

- **Role**: Set to `Aggregator`, which means it will run as a StatefulSet.
- **Replicas**: 1
- **Service**: Enabled with type `ClusterIP`.
- **Existing ConfigMaps**: Uses `vector-agent-config-2658c2h57d` for configuration.

### Values

The following values are defined for the `vector-agent`:

- **Image**: 
  - Repository: `timberio/vector`
  - Pull Policy: `IfNotPresent`
  - Tag: Derived from the chart's appVersion.
  
- **Service Configuration**:
  - Enabled: `true`
  - Type: `ClusterIP`
  
- **Pod Management**:
  - Pod Management Policy: `OrderedReady`
  
- **Resource Requests and Limits**: Can be defined in the `resources` section (currently empty).

- **Logging Level**: Set to `info`.

## Helm Repository

The Helm chart is sourced from the following repository:

- **Name**: `vector`
- **URL**: [https://helm.vector.dev](https://helm.vector.dev)
- **Update Interval**: 24 hours

## Image Management

The component uses images from two repositories:

1. **Vector Helm Chart**: 
   - Image: `ghcr.io/vectordotdev/helm-charts/vector`
   - Update Interval: 24 hours

2. **Vector Docker Hub**:
   - Image: `timberio/vector`
   - Update Interval: 24 hours

## Monitoring

The `vector-agent` can be monitored using a PodMonitor, which is currently disabled. If enabled, it would scrape metrics from the configured endpoints.

## Additional Notes

- The `vector-agent` is designed to be highly configurable, allowing for various deployment scenarios and resource management strategies.
- Ensure that any sensitive information is managed securely, especially when configuring secrets and environment variables.

For further details on configuration options, refer to the [Vector documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
