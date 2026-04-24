---
title: "envoy-gateway"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# envoy-gateway

## Overview
The `envoy-gateway` component serves as a gateway for managing incoming traffic to services within the Kubernetes cluster. It utilizes Envoy Proxy to provide advanced traffic management features, including load balancing, traffic routing, and telemetry. This deployment consists of multiple EnvoyProxy configurations and Gateway resources to handle both public and private traffic efficiently.

## Sub-components
This deployment does not have multiple HelmReleases.

## Dependencies
This deployment does not have any dependencies.

## Helm Chart(s)
This deployment does not utilize Helm charts.

## Resource Glossary
### Networking Resources
- **GatewayClass**: Defines a class of gateways that can be managed by the Envoy Proxy controller. It specifies the controller name as `gateway.envoyproxy.io/gatewayclass-controller`.
  
- **Gateway**: Represents a network gateway that manages traffic routing. Three Gateway resources are defined:
  - `envoy-gw`: Handles HTTP and HTTPS traffic for the domain `wahoo.li` and terminates TLS using a specified secret.
  - `envoy-gw-private`: Similar to `envoy-gw`, but also manages traffic for the domain `absolutist.it` and includes additional HTTP and HTTPS listeners.
  - `envoy-gw-ai`: A dedicated gateway for AI-related traffic, configured to handle HTTP requests.

- **HTTPRoute**: Defines routing rules for HTTP traffic. The `envoy-gw-private-https-redirect` resource redirects HTTP traffic to HTTPS for specified hostnames.

### Service Resources
- **Service**: Two ClusterIP services are defined:
  - `envoy-gw-ai-nas`: Exposes the `envoy-gw-ai` gateway for internal traffic on port 80, targeting port 10080.
  - `envoy-gw-ai-tpi-1`: Another service for internal traffic, configured to handle HTTP requests.

### Traffic Policies
- **ClientTrafficPolicy**: Two policies that define how client traffic is managed:
  - `envoy-gw-public-policy`: Configures client IP detection and connection limits for the public gateway.
  - `envoy-gw-private-policy`: Similar configuration for the private gateway.

- **BackendTrafficPolicy**: Two policies that manage backend traffic:
  - `envoy-gw-compression`: Enables Gzip and Brotli compression for responses from the public and private gateways.
  - `media-streaming`: Configures timeout settings for media streaming services.

## Configuration Highlights
- **Replicas**: Each EnvoyProxy configuration specifies a replica count of 1.
- **Rolling Update Strategy**: Both EnvoyProxy configurations use a rolling update strategy with a maximum of 1 unavailable pod during updates.
- **Telemetry**: Access logs are configured in JSON format, outputting various request and response metrics to stdout.
- **TLS Configuration**: The gateways utilize TLS termination with certificates managed by cert-manager.

## Deployment
- **Target Namespace**: `envoy-gateway-system`
- **Release Names**: Not applicable as there are no HelmReleases.
- **Reconciliation Interval**: Not specified.
- **Install/Upgrade Behavior**: Not specified.
