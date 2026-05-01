---
title: "envoy-gateway"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# envoy-gateway

## Overview
The `envoy-gateway` component serves as a gateway for managing traffic routing within the Kubernetes cluster named `nas`. It utilizes Envoy Proxy to handle incoming requests and route them to appropriate services based on defined rules. This deployment includes multiple gateways for public and private traffic, ensuring secure and efficient communication across services.

## Sub-components
This deployment consists of multiple EnvoyProxy configurations and gateways, each serving different traffic patterns and purposes.

## Dependencies
There are no explicit dependencies defined in the manifests for this component.

## Helm Chart(s)
- **Chart Name**: envoy-gateway
- **Repository**: gateway.envoyproxy.io
- **Version**: latest

## Resource Glossary
### Networking
- **Gateway**: Defines entry points for traffic into the cluster. Multiple gateways are configured for different protocols (HTTP, HTTPS, TCP) and hostnames, allowing for flexible routing.
- **HTTPRoute**: Specifies routing rules for HTTP traffic, including redirection from HTTP to HTTPS.
- **Service**: Exposes the Envoy Proxy to handle incoming traffic. Services are defined for different gateways, ensuring that traffic is directed to the correct Envoy instance.

### Security
- **ClientTrafficPolicy**: Manages policies related to client traffic, such as connection limits and IP detection settings.
- **BackendTrafficPolicy**: Configures policies for backend services, including compression settings for responses.

### Load Balancing
- **GatewayClass**: Defines the class of gateways that Envoy will manage, allowing for custom configurations and behaviors.

## Configuration Highlights
- **Replicas**: Each EnvoyProxy deployment is configured with 1 replica to ensure high availability.
- **Rolling Update Strategy**: A rolling update strategy is employed to minimize downtime during updates, allowing for 1 unavailable pod at a time.
- **Telemetry**: Access logs are configured in JSON format, providing detailed insights into traffic patterns and performance metrics.
- **TLS Configuration**: The gateways are set up to terminate TLS connections, using secrets for certificate management.

## Deployment
- **Target Namespace**: `envoy-gateway-system`
- **Release Names**: Various gateways and EnvoyProxy configurations as specified in the manifests.
- **Reconciliation Interval**: Managed by Flux, with no specific interval mentioned in the manifests.
- **Install/Upgrade Behavior**: The deployment follows standard Helm practices, with configurations applied as defined in the manifests.
