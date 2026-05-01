---
title: "envoy-gateway"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# envoy-gateway

## Overview
The `envoy-gateway` component serves as a gateway for managing traffic in the Kubernetes cluster `tpi-1`. It utilizes Envoy Proxy to handle incoming requests, providing features such as traffic routing, load balancing, and telemetry. This deployment consists of multiple EnvoyProxy configurations and Gateway resources to facilitate both public and private traffic management.

## Sub-components
This deployment does not contain multiple HelmReleases.

## Dependencies
There are no dependencies specified for this component.

## Helm Chart(s)
This component does not specify a Helm chart as it is deployed using Kustomize-rendered manifests.

## Resource Glossary
### Networking Resources
- **Gateway**: Defines entry points for traffic into the cluster. The `envoy-gw`, `envoy-gw-private`, and `envoy-gw-ai` Gateways manage HTTP and HTTPS traffic, while `envoy-gw-voice` handles TCP traffic.
- **HTTPRoute**: Manages routing rules for HTTP traffic. The `envoy-gw-private-https-redirect` HTTPRoute redirects HTTP requests to HTTPS for specified hostnames.
- **Service**: Exposes the Envoy Proxy deployments internally. The `envoy-gw-ai-tpi-1` and `envoy-gw-ai-nas` Services route traffic to the corresponding Envoy Proxy instances.

### Traffic Policies
- **ClientTrafficPolicy**: Defines policies for managing client traffic. The `envoy-gw-public-policy` and `envoy-gw-private-policy` specify settings for client IP detection and connection limits.
- **BackendTrafficPolicy**: Manages backend traffic settings, including compression for the `envoy-gw-compression` policy, which applies Gzip and Brotli compression to responses.

### GatewayClass
- **GatewayClass**: The `envoy-gateway` GatewayClass specifies the controller responsible for managing the gateways, which is the Envoy Proxy in this case.

## Configuration Highlights
- **Replicas**: The `envoy-proxy-config` specifies 4 replicas for the main Envoy deployment, while the `envoy-proxy-ai-config` specifies 1 replica.
- **Rolling Update Strategy**: Both EnvoyProxy configurations use a rolling update strategy with a maximum of 1 unavailable instance during updates.
- **Telemetry**: Access logs are configured in JSON format, with metrics enabled for Prometheus.
- **TLS Configuration**: The Gateways are configured to use TLS termination with certificates managed by cert-manager.

## Deployment
- **Target Namespace**: `envoy-gateway-system`
- **Release Name**: Not applicable as this is not deployed via Helm.
- **Reconciliation Interval**: Not specified.
- **Install/Upgrade Behavior**: Not specified.
