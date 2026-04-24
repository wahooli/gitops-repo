---
title: "envoy-gateway"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# envoy-gateway

## Overview
The `envoy-gateway` component serves as a gateway for managing incoming traffic to services within the Kubernetes cluster `tpi-1`. It leverages Envoy Proxy to provide advanced traffic management capabilities, including routing, load balancing, and observability. This deployment consists of multiple EnvoyProxy configurations and Gateway resources to handle both public and private traffic effectively.

## Sub-components
This deployment does not have multiple HelmReleases.

## Dependencies
This deployment does not have any dependencies.

## Helm Chart(s)
This deployment does not utilize Helm charts.

## Resource Glossary
### Networking Resources
- **GatewayClass**: Defines a class of gateways, in this case, `envoy-gateway`, which is managed by the Envoy Proxy controller.
- **Gateway**: Represents a network gateway that manages traffic routing. There are three Gateway resources:
  - `envoy-gw`: Handles HTTP and HTTPS traffic for the domain `wahoo.li` with TLS termination.
  - `envoy-gw-private`: Manages internal traffic for both `wahoo.li` and `absolutist.it`, also with TLS termination.
  - `envoy-gw-ai`: Dedicated to handling HTTP traffic for AI-related services.
- **HTTPRoute**: Defines routing rules for HTTP traffic. The `envoy-gw-private-https-redirect` resource redirects HTTP traffic to HTTPS for specified hostnames.

### Service Resources
- **Service**: Two ClusterIP services are defined:
  - `envoy-gw-ai-tpi-1`: Exposes the `envoy-gw-ai` gateway for HTTP traffic.
  - `envoy-gw-ai-nas`: Provides internal traffic routing for AI services.

### Traffic Policies
- **ClientTrafficPolicy**: Two policies are defined to manage client traffic:
  - `envoy-gw-public-policy`: Limits the number of connections and manages client IP detection for the public gateway.
  - `envoy-gw-private-policy`: Configures settings for the private gateway, including HTTP/3 support.
- **BackendTrafficPolicy**: Two policies manage backend traffic:
  - `envoy-gw-compression`: Enables compression for responses from the public and private gateways.
  - `media-streaming`: Configures timeout settings for media streaming services.

## Configuration Highlights
- **EnvoyProxy Configurations**:
  - `envoy-proxy-config`: Configured with 4 replicas for high availability and rolling updates.
  - `envoy-proxy-ai-config`: Configured with 1 replica for AI services.
- **Gateway Annotations**: Utilizes `cert-manager` for TLS certificates and external DNS annotations for hostname management.
- **Traffic Management**: Includes request redirection from HTTP to HTTPS and compression settings for improved performance.

## Deployment
- **Target Namespace**: `envoy-gateway-system`
- **Release Names**: Not applicable as there are no HelmReleases.
- **Reconciliation Interval**: Not specified.
- **Install/Upgrade Behavior**: Not specified.
