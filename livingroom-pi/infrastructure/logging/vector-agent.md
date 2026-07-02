---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "livingroom-pi"
---

# vector-agent

The `vector-agent` component is deployed in the `livingroom-pi` cluster using FluxCD to manage its lifecycle through Helm. This component is responsible for collecting and processing logs and metrics.

## Overview

- **Helm Chart**: `vector`
- **Version**: `0.56.0`
- **Release Name**: `vector-agent`
- **Namespace**: `logging`
- **Interval for Updates**: `10m`
- **Dependencies**: Depends on `victoria-metrics--victoria-metrics-operator`

## Configuration

The `vector-agent` is configured using values from existing ConfigMaps and custom values defined in the HelmRelease. The following key configurations are applied:

- **Role**: `Aggregator`
- **Replicas**: `1`
- **Service**: Enabled with type `ClusterIP`
- **Existing ConfigMaps**: Uses `vector-agent-config-2658c2h57d`
- **Values from ConfigMap**: 
  - `values-base.yaml`
  - `values.yaml`

### Key Values

- **Image**: 
  - Repository: `timberio/vector`
  - Pull Policy: `IfNotPresent`
- **Pod Management Policy**: `OrderedReady`
- **Termination Grace Period**: `60 seconds`
- **Log Level**: `info`

### Persistence

- **Persistence**: 
  - Enabled: `false`
  - Host Path: `/var/lib/vector`

### Service Configuration

- **Service Enabled**: `true`
- **Service Type**: `ClusterIP`
- **Headless Service**: Enabled

## Monitoring

The component can be monitored using a PodMonitor, which is currently disabled. If enabled, it would scrape metrics from the Vector pods.

## Helm Repository

The Helm chart is sourced from the following repository:

- **Repository Name**: `vector`
- **URL**: `https://helm.vector.dev`
- **Update Interval**: `24h`

## Image Repositories

Two image repositories are defined for the `vector-agent`:

1. **Vector Helm Chart**: 
   - Image: `ghcr.io/vectordotdev/helm-charts/vector`
   - Update Interval: `24h`
   
2. **Vector Docker Hub**: 
   - Image: `timberio/vector`
   - Update Interval: `24h`

## Additional Notes

- Ensure that the necessary ConfigMaps are created and available in the `logging` namespace for the `vector-agent` to function correctly.
- Review the [Vector documentation](https://vector.dev/docs/setup/installation/package-managers/helm/) for more details on configuration options and best practices.
