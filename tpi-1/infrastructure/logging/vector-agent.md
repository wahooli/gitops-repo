---
title: "vector-agent"
parent: "Infrastructure / Logging"
grand_parent: "tpi-1"
---

# Vector Agent

The `vector-agent` component is a deployment of the [Vector](https://vector.dev/) observability tool in the `tpi-1` Kubernetes cluster. It is managed using a Flux `HelmRelease` and is configured to act as an "Aggregator" for log collection and processing.

## Overview

- **Cluster**: `tpi-1`
- **Namespace**: `logging`
- **Helm Chart**: `vector` (version `0.51.0`)
- **Helm Repository**: `vector` (namespace: `flux-system`)
- **Release Name**: `vector-agent`
- **Chart Role**: `Aggregator` (deployed as a StatefulSet)

## Dependencies

The `vector-agent` deployment depends on the following components:
- `victoria-metrics--victoria-metrics-operator` (namespace: `flux-system`)
- `logging--vector-global-write` (namespace: `flux-system`)

## Configuration

The `vector-agent` is configured using a combination of values specified directly in the `HelmRelease` and external configuration files provided via `ConfigMap`. Below are the key configuration details:

### Values

- **Role**: `Aggregator`
- **Replicas**: `1`
- **Image**:
  - Repository: `timberio/vector`
  - Pull Policy: `IfNotPresent`
  - Tag: Derived from the chart's `appVersion`
- **RBAC**: Enabled
- **Service Account**: Created with auto-mounting of API credentials enabled
- **Pod Annotations**: 
  - `vector.dev/exclude: "true"`
- **Pod Labels**: None specified
- **Service**:
  - Type: `ClusterIP`
  - Headless Service: Enabled
- **Persistence**:
  - Enabled: `false`
  - Host Path: `/var/lib/vector`
- **Probes**:
  - Liveness Probe: Not configured
  - Readiness Probe: Not configured
- **Autoscaling**: Disabled
- **Pod Disruption Budget**: Disabled
- **HAProxy Load Balancer**: Disabled

### External Configuration

The following `ConfigMap` resources are used to provide additional configuration:
- `vector-agent-values-2g77gh45fc`:
  - `values-base.yaml`: Contains default values for Vector, including image configuration, role, and resource settings.
  - `values.yaml`: Contains additional custom values.

Additionally, the `vector-agent` references the existing ConfigMap `vector-agent-config-ktmd8gg8f6` for its configuration.

## Image Automation

The `vector-agent` deployment uses Flux's image automation capabilities to manage the container image:

- **Image Repository**: `timberio/vector` (source: Docker Hub)
- **Image Policy**:
  - Tag Pattern: `^([0-9]+\.[0-9]+\.[0-9]+)-debian$`
  - Policy: Semantic versioning (`x.x.x`)

## Deployment Details

- **Update Interval**: 10 minutes
- **Install Remediation**: Unlimited retries
- **Target Namespace**: `logging`
- **Existing ConfigMaps**: `vector-agent-config-ktmd8gg8f6`
- **Pod Management Policy**: `OrderedReady`

## Additional Notes

- The `vector-agent` is configured to use a checksum of the generated `ConfigMap` for workload annotations to ensure proper rolling updates.
- The deployment does not currently use persistent storage for the `Aggregator` role, relying instead on hostPath storage at `/var/lib/vector`.
- The component does not expose an Ingress or enable metrics scraping via a `PodMonitor`.

For more details on Vector configuration, refer to the [Vector Helm Chart documentation](https://vector.dev/docs/setup/installation/package-managers/helm/).
