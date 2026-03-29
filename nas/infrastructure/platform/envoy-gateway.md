---
title: "envoy-gateway"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# envoy-gateway

## Overview

The `envoy-gateway` component is a deployment of the Envoy Gateway, which provides a robust, scalable, and extensible API Gateway solution for managing ingress and egress traffic in the Kubernetes cluster `nas`. It leverages the Gateway API and Envoy Proxy to handle HTTP(S) traffic, routing, and advanced traffic management features such as telemetry, traffic policies, and compression.

This deployment includes multiple Gateway resources to handle both public and private traffic, along with associated policies for traffic management and security.

## Resource Glossary

### Networking Resources

- **GatewayClass (`envoy-gateway`)**: Defines the `envoy-gateway` class, which is managed by the `gateway.envoyproxy.io/gatewayclass-controller`. This class is used by Gateway resources to specify the controller responsible for managing them.

- **Gateway (`envoy-gw`)**: A public-facing gateway in the `envoy-gateway-system` namespace. It listens on HTTP (port 80) and HTTPS (port 443) for traffic to `*.wahoo.li`. TLS termination is configured using a wildcard certificate stored in the `wahooli-wildcard-tls` Secret.

- **Gateway (`envoy-gw-private`)**: A private gateway in the `envoy-gateway-system` namespace. It listens on HTTP (port 80) and HTTPS (port 443) for traffic to `*.wahoo.li` and `*.absolutist.it`. TLS termination is configured using wildcard certificates stored in the `wahooli-wildcard-tls` and `absolutistit-wildcard-tls` Secrets.

- **HTTPRoute (`envoy-gw-private-https-redirect`)**: Configures an HTTP-to-HTTPS redirect for traffic to `*.wahoo.li` and `*.absolutist.it` on the `envoy-gw-private` Gateway.

### Traffic Policies

- **ClientTrafficPolicy (`envoy-gw-public-policy`)**: Configures client traffic policies for the public Gateway (`envoy-gw`). Includes settings for client IP detection, connection limits, and disabling Envoy headers.

- **ClientTrafficPolicy (`envoy-gw-private-policy`)**: Configures client traffic policies for the private Gateway (`envoy-gw-private`). Includes settings for HTTP/3 support and disabling Envoy headers.

- **BackendTrafficPolicy (`envoy-gw-compression`)**: Configures backend traffic policies for both the public and private Gateways. Enables Gzip and Brotli compression for responses.

- **BackendTrafficPolicy (`media-streaming`)**: Configures backend traffic policies for specific HTTPRoutes (`plex` and `jellyfin`) in the `default` namespace. Includes extended timeouts for idle connections and requests to support media streaming.

### Security Resources

- **ReferenceGrant (`envoy-gw-tls-secrets`)**: Allows the Gateways in the `envoy-gateway-system` namespace to reference Secrets in the `infrastructure` namespace for TLS configuration.

### Envoy Proxy Configuration

- **EnvoyProxy (`envoy-proxy-config`)**: Configures the Envoy Proxy deployment in the `envoy-gateway-system` namespace. Includes:
  - **Provider**: Specifies Kubernetes as the provider with a single replica and rolling update strategy.
  - **Telemetry**: Configures access logs in JSON format and enables Prometheus metrics.
  - **Topology Spread Constraints**: Ensures even distribution of pods across nodes to improve availability.

## Configuration Highlights

- **Replica Count**: The Envoy Proxy deployment is configured with a single replica.
- **Rolling Update Strategy**: The deployment uses a rolling update strategy with a maximum of one unavailable pod during updates.
- **Telemetry**: Access logs are configured in JSON format with detailed request and response data. Prometheus metrics are enabled by default.
- **TLS Termination**: TLS is terminated at the Gateway level using wildcard certificates stored in Secrets.
- **Compression**: Gzip and Brotli compression are enabled for backend traffic.
- **Timeouts**: Extended timeouts are configured for media streaming routes to support long-lived connections.

## Deployment

- **Target Namespaces**: The primary namespace for this deployment is `envoy-gateway-system`. Some resources, such as TLS Secrets, are located in the `infrastructure` namespace.
- **Reconciliation**: Managed by Flux with a reconciliation interval defined in the Flux configuration.
- **Configurable Parameters**: The deployment uses Flux variables for dynamic configuration, including:
  - `${envoy_gw_lb_ip}`: Load balancer IP for the public Gateway.
  - `${envoy_gw_private_lb_ip}`: Load balancer IP for the private Gateway.
  - `${domain_wahoo_li}`: Domain for public traffic.
  - `${domain_absolutist_it}`: Domain for private traffic.

This deployment is designed to provide a scalable and secure ingress solution for both public and private traffic in the cluster.
