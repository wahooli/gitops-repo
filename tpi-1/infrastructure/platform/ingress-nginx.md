---
title: "ingress-nginx"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# ingress-nginx

## Overview

The `ingress-nginx` component provides an Ingress Controller for managing HTTP and HTTPS traffic to Kubernetes services in the `tpi-1` cluster. It is based on the popular [ingress-nginx](https://kubernetes.github.io/ingress-nginx) Helm chart and is deployed using Flux's GitOps methodology. This component ensures that external traffic is routed to the appropriate services within the cluster, supporting features like load balancing, SSL termination, and advanced traffic routing.

## Helm Chart(s)

### ingress-nginx
- **Chart Name**: ingress-nginx  
- **Repository**: [ingress-nginx](https://kubernetes.github.io/ingress-nginx)  
- **Version**: 4.11.5  

## Resource Glossary

### Networking
- **Service (2)**: Exposes the Ingress Controller to handle HTTP and HTTPS traffic. One service is configured as a `LoadBalancer` to allow external access.
- **IngressClass (1)**: Defines the `nginx` ingress class, which is used by the Ingress Controller to manage ingress resources.

### Security
- **ServiceAccount (1)**: Provides an identity for the Ingress Controller to interact with the Kubernetes API.
- **Role (1) and RoleBinding (1)**: Grants permissions to the ServiceAccount for managing resources within the `ingress-nginx` namespace.
- **ClusterRole (1) and ClusterRoleBinding (1)**: Grants cluster-wide permissions to the ServiceAccount for managing resources like ingresses, services, and endpoints.

### Workload
- **Deployment (1)**: Runs the Ingress Controller pods, which handle incoming HTTP/HTTPS requests and route them to the appropriate backend services.

### Configuration
- **ConfigMap (1)**: Stores configuration settings for the Ingress Controller, such as logging format, HTTP settings, and other advanced configurations.

### Admission Control
- **ValidatingWebhookConfiguration (1)**: Enables admission webhooks for validating Ingress resources managed by the Ingress Controller.

## Configuration Highlights

- **Controller Settings**:
  - Admission webhooks are enabled with a timeout of 30 seconds.
  - The `nginx` ingress class is set as the default for the cluster.
  - The controller uses a `LoadBalancer` service type with external traffic policy set to `Local`.
  - Metrics collection is enabled, but `ServiceMonitor` and `PrometheusRule` are disabled.
  - Advanced logging is configured with JSON formatting and custom log levels based on HTTP status codes.
  - HTTP/2, gzip, and Brotli compression are enabled for improved performance.
  - The controller supports `use-forwarded-headers`, `proxy-real-ip-cidr`, and `use-proxy-protocol` for handling client IPs and proxy headers.
  - Custom HTTP snippets are included for advanced logging and response time mapping.

- **DNS and External Annotations**:
  - DNS options include setting `ndots` to 3.
  - External DNS annotations are configured for hostname resolution and IP allocation.

- **Replica Count**:
  - The Ingress Controller is configured to run with a single replica.

- **Topology Spread Constraints**:
  - Ensures even distribution of pods across nodes to improve availability and fault tolerance.

## Deployment

- **Target Namespace**: `ingress-nginx`  
- **Release Name**: `ingress-nginx`  
- **Reconciliation Interval**: 10 minutes  
- **Install Behavior**: Retries indefinitely on failure with a timeout of 5 minutes.  
- **Upgrade Behavior**: Automatically remediates the last failure during upgrades.  

This component is managed by Flux and uses multiple ConfigMaps for configuration values, allowing for flexible and dynamic updates. The HelmRelease references these ConfigMaps for base, additional, and override configurations, making it highly customizable.
