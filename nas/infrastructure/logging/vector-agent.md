---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "nas"
---

# vector-agent

The `vector-agent` component is deployed in the `flux-system` namespace of the `nas` cluster. It utilizes the Vector logging agent to collect and process logs.

## Overview

- **Helm Chart**: `vector`
- **Version**: `0.57.0`
- **Release Name**: `vector-agent`
- **Target Namespace**: `logging`
- **Deployment Type**: Aggregator (StatefulSet)

## Dependencies

The `vector-agent` HelmRelease depends on the following components:
- `victoria-metrics--victoria-metrics-operator` (namespace: `flux-system`)
- `logging--vector-global-write` (namespace: `flux-system`)

## Configuration

The configuration for the `vector-agent` is primarily managed through ConfigMaps and Helm values. The following key configurations are defined:

### Values from ConfigMaps
- **Base Values**: Configured through `vector-agent-values-76hc5h25f6` with keys:
  - `values-base.yaml`
  - `values.yaml`

### Key Configuration Options
- **Role**: `Aggregator`
- **Replicas**: `1`
- **Service**: Enabled with type `ClusterIP`
- **Pod Management Policy**: `OrderedReady`
- **Log Level**: `info`
- **Termination Grace Period**: `60 seconds`

### Resource Management
- **Resource Requests and Limits**: Not explicitly defined, defaults will apply.
- **Pod Disruption Budget**: Disabled by default.

### Persistence
- **Persistence**: Not enabled by default, but can be configured to use hostPath for data storage.

### Security Context
- **RBAC**: Enabled for the service account.
- **Pod Security Context**: Default settings apply.

## Image Repository

The component uses the following image repository:
- **Image**: `timberio/vector`
- **Image Policy**: `vector-debian` with a semver range policy.

## Monitoring

The component does not have a PodMonitor enabled by default, but it can be configured if required.

## Additional Notes

- Ensure that the existing ConfigMaps referenced in the configuration are created and available in the `logging` namespace.
- The component is designed to work in conjunction with other logging and monitoring tools within the cluster.
