---
title: "envoy-gateway"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# envoy-gateway

## Overview

The `envoy-gateway` component is a deployment of the Envoy Gateway, which provides API Gateway functionality based on the Kubernetes Gateway API. It enables advanced traffic management, routing, and observability for HTTP and HTTPS traffic within the cluster. This deployment includes configurations for public and private gateways, traffic policies, and logging/telemetry settings.

## Resource Glossary

### Networking Resources
- **GatewayClass (`envoy-gateway`)**: Defines the `GatewayClass` resource for the Envoy Gateway, specifying the controller responsible for managing gateways (`gateway.envoyproxy.io/gatewayclass-controller`).
- **Gateway (`envoy-gw`)**: A public gateway resource in the `envoy-gateway-system` namespace. It listens on HTTP (port 80) and HTTPS (port 443) for the `*.wahoo.li` domain and uses a TLS certificate from the `wahooli-wildcard-tls` secret.
- **Gateway (`envoy-gw-private`)**: A private gateway resource in the `envoy-gateway-system` namespace. It listens on HTTP (port 80) and HTTPS (port 443) for both `*.wahoo.li` and `*.absolutist.it` domains, using TLS certificates from the `wahooli-wildcard-tls` and `absolutistit-wildcard-tls` secrets.
- **HTTPRoute (`envoy-gw-private-https-redirect`)**: Redirects HTTP traffic to HTTPS for the private gateway (`envoy-gw-private`) on both `*.wahoo.li` and `*.absolutist.it` domains with a 301 status code.

### Traffic Policies
- **ClientTrafficPolicy (`envoy-gw-public-policy`)**: Configures client traffic policies for the public gateway (`envoy-gw`), including connection limits, disabling Envoy headers, and enabling X-Forwarded-For headers with one trusted hop.
- **ClientTrafficPolicy (`envoy-gw-private-policy`)**: Configures client traffic policies for the private gateway (`envoy-gw-private`), including disabling Envoy headers and enabling HTTP/3.
- **BackendTrafficPolicy (`envoy-gw-compression`)**: Configures backend compression policies (Gzip and Brotli) for both the public and private gateways.
- **BackendTrafficPolicy (`media-streaming`)**: Configures backend traffic policies for media streaming services (`plex` and `jellyfin` HTTPRoutes) with a connection idle timeout of 3600 seconds and no request timeout.

### Security Resources
- **ReferenceGrant (`envoy-gw-tls-secrets`)**: Grants the `envoy-gateway-system` namespace access to TLS secrets (`wahooli-wildcard-tls` and `absolutistit-wildcard-tls`) in the `infrastructure` namespace.

### EnvoyProxy Configuration
- **EnvoyProxy (`envoy-proxy-config`)**: Configures the Envoy Proxy deployment in the `envoy-gateway-system` namespace. Key settings include:
  - **Provider**: Uses Kubernetes as the provider with a deployment strategy of 4 replicas and rolling updates.
  - **Telemetry**: Configures JSON-formatted access logs with detailed request and response information, excluding traffic to `crowdsec-api.absolutist.it`. Prometheus metrics are enabled.

## Configuration Highlights

- **Replica Count**: The Envoy Proxy deployment is configured with 4 replicas for high availability.
- **Rolling Update Strategy**: Allows one unavailable replica during updates to ensure minimal downtime.
- **Access Logs**: JSON-formatted logs with detailed request and response data are written to `/dev/stdout`.
- **TLS Certificates**: TLS termination is configured for both public and private gateways using secrets (`wahooli-wildcard-tls` and `absolutistit-wildcard-tls`).
- **Traffic Policies**: Includes client connection limits, HTTP/3 support, and backend compression for optimized performance.
- **Customizable Parameters**: The deployment uses Flux variables (e.g., `${envoy_gw_lb_ip}`, `${domain_wahoo_li}`, `${domain_absolutist_it}`) for IP addresses and domain names, allowing for flexible configuration.

## Deployment

- **Target Namespace**: `envoy-gateway-system`
- **Reconciliation Interval**: Managed by Flux with automatic reconciliation of changes.
- **Install/Upgrade Behavior**: Changes to the configuration are automatically applied by Flux, ensuring the deployment remains up-to-date with the desired state.

This deployment provides a robust and scalable API Gateway solution for managing HTTP and HTTPS traffic in the `tpi-1` cluster.
