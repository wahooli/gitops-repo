---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "livingroom-pi"
---

# vector-agent

The `vector-agent` component is deployed in the `livingroom-pi` cluster using Flux and Helm. It is responsible for collecting and processing logs and metrics from various sources.

## Overview

- **Chart**: vector
- **Version**: 0.57.0
- **Release Name**: vector-agent
- **Namespace**: logging
- **Helm Repository**: [vector](https://helm.vector.dev)

## Dependencies

The `vector-agent` HelmRelease depends on the following component:
- **victoria-metrics--victoria-metrics-operator** (namespace: flux-system)

## Configuration

The `vector-agent` is configured using the following values:

- **Role**: Aggregator
- **Replicas**: 1
- **Image**: timberio/vector
- **Service**: Enabled (type: ClusterIP)
- **Existing ConfigMaps**: 
  - vector-agent-config-2658c2h57d

### Values from ConfigMaps

The configuration values are sourced from the following ConfigMaps:
- **ConfigMap**: vector-agent-values-67kkb858d2
  - **Key**: values-base.yaml
  - **Key**: values.yaml

## Resource Management

The `vector-agent` deployment includes the following Kubernetes resources:

- **DaemonSet**: Manages the deployment of the Vector agent across the nodes in the cluster.
- **Service**: Exposes the Vector agent for internal communication.
- **ConfigMap**: Holds configuration data for the Vector agent.

## Image Management

The component utilizes images from the following repositories:
- **Image Repository**: ghcr.io/vectordotdev/helm-charts/vector
- **Image Policy**: 
  - **Name**: vector-helm-chart
  - **Policy**: semver range
- **Image Repository**: timberio/vector
- **Image Policy**: 
  - **Name**: vector-debian
  - **Filter Tags**: Extracts version from tags matching the pattern `^(?P<version>[0-9]+\.[0-9]+\.[0-9]+)-debian$`

## Additional Information

For more details on configuring and using Vector, refer to the official documentation: [Vector Documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
