---
title: "client-lookup"
parent: "Infrastructure / Internal-dns"
grand_parent: "nas"
---

# client-lookup

The `client-lookup` component is a DNS service deployed in the `nas` Kubernetes cluster. It is based on the CoreDNS Helm chart and is managed using Flux's GitOps methodology. This document provides an overview of the deployment configuration and key details.

## Overview

The `client-lookup` component is deployed using the `coredns` Helm chart from the official CoreDNS Helm repository. It is configured to run as an internal DNS service within the `internal-dns` namespace.

### Helm Chart Details

- **Chart Name**: `coredns`
- **Chart Repository**: [https://coredns.github.io/helm](https://coredns.github.io/helm)
- **Chart Version**: `latest` (floating version)
- **Release Name**: `client-lookup`
- **Namespace**: `internal-dns`

## Deployment Configuration

### HelmRelease

The `client-lookup` HelmRelease is configured as follows:

- **Source Reference**: 
  - Kind: `HelmRepository`
  - Name: `coredns`
  - Namespace: `flux-system`
- **Install Configuration**:
  - Remediation: Enabled with unlimited retries (`retries: -1`)
  - Timeout: `10m`
- **Sync Interval**: `5m`
- **Values Source**: 
  - Primary configuration is sourced from the `client-lookup-values-7fm48tb256` ConfigMap in the `flux-system` namespace.
  - Keys used:
    - `values-base.yaml` (mandatory)
    - `values-shared.yaml` (optional)
    - `values.yaml` (optional)

### CoreDNS Configuration

The CoreDNS deployment is configured with the following key settings:

- **Image**:
  - Repository: `coredns/coredns`
  - Tag: Default (matches the chart's `appVersion`)
  - Pull Policy: `IfNotPresent`
- **Replicas**: 1
- **Resource Requests and Limits**:
  - CPU: `100m`
  - Memory: `128Mi`
- **Service**:
  - Type: `ClusterIP`
- **RBAC**:
  - Enabled: `true`
- **Probes**:
  - Liveness Probe: Enabled
    - Initial Delay: `60s`
    - Period: `10s`
    - Timeout: `5s`
    - Failure Threshold: `5`
  - Readiness Probe: Enabled
    - Initial Delay: `30s`
    - Period: `10s`
    - Timeout: `5s`
    - Failure Threshold: `5`
- **Autoscaler**: Disabled
- **Horizontal Pod Autoscaler (HPA)**: Disabled
- **Pod Disruption Budget**: Not configured
- **Custom Zone Files**: Not configured
- **Affinity, Tolerations, and Node Selector**: Not configured

### ImageRepository

An `ImageRepository` resource is configured to monitor the CoreDNS image:

- **Image**: `coredns/coredns`
- **Sync Interval**: `24h`

## Additional Notes

- The deployment uses a floating version of the CoreDNS Helm chart (`latest`), which means it will automatically track the latest version available in the repository.
- The `client-lookup` service is configured as a cluster service (`isClusterService: true`), making it accessible across the cluster.
- The deployment does not currently enable metrics collection for Prometheus or any autoscaling features.

For further customization, update the values in the `client-lookup-values-7fm48tb256` ConfigMap or modify the HelmRelease configuration.
