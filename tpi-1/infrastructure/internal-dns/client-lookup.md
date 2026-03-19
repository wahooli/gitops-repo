---
title: "client-lookup"
parent: "Infrastructure / Internal-dns"
grand_parent: "tpi-1"
---

# client-lookup

The `client-lookup` component is a DNS service deployed in the `tpi-1` cluster using the CoreDNS Helm chart. It is managed via a Flux HelmRelease and configured to run in the `internal-dns` namespace.

## Helm Chart Details

- **Chart Name**: `coredns`
- **Chart Version**: `latest` (retrieved from `https://coredns.github.io/helm`)
- **Release Name**: `client-lookup`
- **Namespace**: `internal-dns`

## Configuration

The `client-lookup` component is configured using values provided in the following ConfigMaps:

1. **Base Values**: `client-lookup-values-7fm48tb256` (key: `values-base.yaml`)
2. **Shared Values** (optional): `client-lookup-values-7fm48tb256` (key: `values-shared.yaml`)
3. **Custom Values** (optional): `client-lookup-values-7fm48tb256` (key: `values.yaml`)

### Key Configuration Parameters

- **Image**:
  - Repository: `coredns/coredns`
  - Tag: Defaults to the chart's `appVersion`
  - Pull Policy: `IfNotPresent`

- **Replica Count**: `1`

- **Resource Requests and Limits**:
  - CPU: `100m`
  - Memory: `128Mi`

- **Service Type**: `ClusterIP`

- **RBAC**:
  - Enabled: `true`
  - PodSecurityPolicy: `false`

- **Probes**:
  - Liveness Probe: Enabled
    - Initial Delay: 60s
    - Period: 10s
  - Readiness Probe: Enabled
    - Initial Delay: 30s
    - Period: 10s

- **Rolling Update Strategy**:
  - Max Unavailable: `1`
  - Max Surge: `25%`

- **Termination Grace Period**: `30s`

- **Horizontal Pod Autoscaler**:
  - Enabled: `false`
  - Min Replicas: `1`
  - Max Replicas: `2`

- **Cluster-Proportional Autoscaler**:
  - Enabled: `false`

## Deployment Details

The `client-lookup` component is deployed as a HelmRelease in the `internal-dns` namespace. The deployment is configured to remediate failures automatically and retry indefinitely. The HelmRelease is reconciled every 5 minutes.

### Kubernetes Resources

The following Kubernetes resources are created as part of the `client-lookup` deployment:

1. **HelmRepository**:
   - Name: `coredns`
   - URL: `https://coredns.github.io/helm`
   - Interval: `24h`

2. **HelmRelease**:
   - Name: `internal-dns--client-lookup`
   - Target Namespace: `internal-dns`
   - Chart: `coredns` (source: `coredns` HelmRepository)
   - Reconciliation Interval: `5m`
   - Install Timeout: `10m`
   - Automatic Failure Remediation: Enabled

3. **ImageRepository**:
   - Name: `coredns`
   - Image: `coredns/coredns`
   - Interval: `24h`

4. **ConfigMap**:
   - Name: `client-lookup-values-7fm48tb256`
   - Contains configuration values for the CoreDNS Helm chart.

## Notes

- The CoreDNS Helm chart is configured with default values for a Kubernetes cluster DNS service. Customizations can be applied via the provided ConfigMaps.
- The `client-lookup` component is designed to act as a cluster-wide DNS service (`isClusterService: true`).
- The deployment does not currently enable Prometheus monitoring or autoscaling features, but these can be configured if needed.
- The HelmRelease is configured to automatically remediate any failures and retry indefinitely.

For more details on the CoreDNS Helm chart, refer to the [official documentation](https://coredns.github.io/helm).
