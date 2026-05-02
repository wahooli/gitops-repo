---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "tpi-1"
---

# vector-agent

The `vector-agent` component is deployed in the `tpi-1` cluster using Flux and Helm. It is responsible for collecting and processing logs and metrics from various sources.

## Overview

- **Helm Chart**: `vector`
- **Version**: `0.52.0`
- **Release Name**: `vector-agent`
- **Namespace**: `logging`
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator`
  - `logging--vector-global-write`
- **Update Interval**: 10 minutes

## Configuration

The `vector-agent` is configured using a combination of Helm values and existing ConfigMaps. The key configurations include:

- **Role**: `Aggregator`
- **Replicas**: 1
- **Service**: Enabled with type `ClusterIP`
- **Existing ConfigMaps**: 
  - `vector-agent-config-bhkk725t2d`
- **Values from ConfigMaps**:
  - `vector-agent-values-4cgtbktdgc` (keys: `values-base.yaml`, `values.yaml`)

### Key Values

- **Image**:
  - Repository: `timberio/vector`
  - Pull Policy: `IfNotPresent`
- **Pod Management Policy**: `OrderedReady`
- **Termination Grace Period**: 60 seconds
- **Log Level**: `info`

### Resource Management

- **Resource Requests and Limits**: Customizable via the `resources` field.
- **Pod Disruption Budget**: Disabled by default.
- **Horizontal Pod Autoscaler**: Disabled by default.

### Networking

- **Service**: 
  - Enabled with default ports.
  - Headless Service: Enabled.
- **Ingress**: Disabled by default.

## Monitoring

- **PodMonitor**: Disabled by default. Can be enabled for Prometheus monitoring.

## Additional Features

- **Persistence**: Not enabled by default, but can be configured for data retention.
- **HAProxy**: Optional load balancer, disabled by default.

## Usage

To deploy or update the `vector-agent`, use the Flux reconciliation process. Ensure that the required ConfigMaps and dependencies are in place before deployment.

For more detailed configuration options, refer to the [Vector Helm documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
