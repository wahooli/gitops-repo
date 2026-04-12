---
title: "envoy-gateway"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# envoy-gateway

## Overview
The `envoy-gateway` component is a Kubernetes-based ingress solution that utilizes Envoy Proxy to manage traffic routing and load balancing within the cluster. It provides HTTP and HTTPS listeners for both public and private access, enabling secure and efficient communication between services. This deployment includes multiple Gateway resources to handle different domains and traffic policies, ensuring robust traffic management.

## Sub-components
This deployment does not include multiple HelmReleases.

## Dependencies
This deployment does not have any dependencies.

## Helm Chart(s)
This deployment does not utilize Helm charts as it is defined using Kustomize-rendered manifests.

## Resource Glossary
### Networking Resources
- **GatewayClass**: Defines a class of gateways that can be managed by the Envoy Proxy controller. It specifies the controller responsible for managing the gateway instances.
- **Gateway**: Represents a network gateway that manages traffic routing. Two Gateway resources are defined:
  - `envoy-gw`: Handles public traffic for the domain `wahoo.li` and `absolutist.it`, with HTTP and HTTPS listeners.
  - `envoy-gw-private`: Manages internal traffic with similar HTTP and HTTPS listeners for the same domains, including specific TLS configurations.
- **HTTPRoute**: Defines routing rules for HTTP traffic. The `envoy-gw-private-https-redirect` resource redirects HTTP requests to HTTPS for specified hostnames.
  
### Traffic Policies
- **ClientTrafficPolicy**: Manages client traffic settings for gateways. Two policies are defined:
  - `envoy-gw-public-policy`: Configures client IP detection and connection limits for the public gateway.
  - `envoy-gw-private-policy`: Configures settings for the private gateway, including HTTP/3 support.
- **BackendTrafficPolicy**: Manages backend traffic settings. Two policies are defined:
  - `envoy-gw-compression`: Enables Gzip and Brotli compression for responses from both public and private gateways.
  - `media-streaming`: Configures timeout settings for specific HTTP routes related to media streaming.

## Configuration Highlights
- **Replica Count**: The Envoy Proxy deployment is configured to run with a single replica.
- **Traffic Policies**: Client and backend traffic policies are defined to manage connection limits, compression, and redirection.
- **TLS Configuration**: The gateways are configured to use TLS certificates stored in Kubernetes Secrets for secure HTTPS traffic.

## Deployment
- **Target Namespace**: `envoy-gateway-system`
- **Release Name**: Not applicable as this deployment is not managed by Helm.
- **Reconciliation Interval**: Not specified in the manifests.
- **Install/Upgrade Behavior**: Not specified in the manifests.
