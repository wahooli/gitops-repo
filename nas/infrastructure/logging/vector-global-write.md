---
title: "vector-global-write"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-global-write

The `vector-global-write` component is deployed in the `flux-system` namespace of the `nas` cluster. It utilizes the Vector logging agent to aggregate logs and metrics from various sources.

## Overview

- **Chart**: Vector
- **Version**: 0.52.0
- **Release Name**: vector-global-write
- **Target Namespace**: logging
- **Installation Interval**: 10 minutes
- **Dependencies**:
  - `victoria-metrics--victoria-metrics-operator`
  - `logging--vector-lb`

## Configuration

The configuration for the Vector instance is primarily defined in the `values-base.yaml` and additional ConfigMaps. Key configurations include:

- **Role**: Aggregator
- **Replicas**: 1
- **Image**: 
  - Repository: `timberio/vector`
  - Pull Policy: `IfNotPresent`
- **Service**: Enabled with type `ClusterIP`
- **Headless Service**: Enabled
- **Pod Disruption Budget**: Disabled
- **RBAC**: Created
- **Service Account**: Created

### Key Values

- **Logging Level**: `info`
- **Termination Grace Period**: 60 seconds
- **Pod Management Policy**: OrderedReady
- **Update Strategy**: RollingUpdate
- **Existing ConfigMaps**: 
  - `vector-global-write-config-bdb5795f69`

### Autoscaling

- **Enabled**: false
- **Min Replicas**: 1
- **Max Replicas**: 10
- **Target CPU Utilization**: 80%

## Resources Created

The deployment creates the following Kubernetes resources:

- **Deployment**: For the Vector Aggregator
- **Service**: For internal communication
- **Headless Service**: For direct pod access
- **ConfigMaps**: For configuration management

## Additional Information

For more details on configuring Vector, refer to the [Vector Helm documentation](https://vector.dev/docs/setup/installation/package-managers/helm/). 

This component is part of a larger logging infrastructure and is designed to work in conjunction with other components such as the Victoria Metrics operator and load balancers.
