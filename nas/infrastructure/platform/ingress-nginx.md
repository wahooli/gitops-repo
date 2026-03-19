---
title: "ingress-nginx"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# ingress-nginx

## Overview

The `ingress-nginx` component provides an Ingress controller for managing HTTP and HTTPS traffic in the Kubernetes cluster. It is responsible for routing external requests to the appropriate services within the cluster based on Ingress rules. This deployment uses the `ingress-nginx` Helm chart version `4.11.5` from the official `ingress-nginx` Helm repository.

## Helm Chart(s)

### ingress-nginx--ingress-nginx
- **Chart Name**: `ingress-nginx`
- **Version**: `4.11.5`
- **Repository**: [ingress-nginx](https://kubernetes.github.io/ingress-nginx)
- **Release Name**: `ingress-nginx`
- **Target Namespace**: `ingress-nginx`

## Resource Glossary

The `ingress-nginx` component creates the following Kubernetes resources:

### Networking
- **Service (2)**: Exposes the Ingress controller to handle HTTP/HTTPS traffic. One of the services is configured as a `LoadBalancer` with `externalTrafficPolicy` set to `Local` for preserving the client source IP.
- **IngressClass (1)**: Defines the `nginx` ingress class, which is set as the default for the cluster.

### Security
- **ServiceAccount (1)**: Used by the Ingress controller for secure communication with the Kubernetes API.
- **Role (1) and RoleBinding (1)**: Provides the necessary permissions for the Ingress controller to manage resources within the `ingress-nginx` namespace.
- **ClusterRole (1) and ClusterRoleBinding (1)**: Grants cluster-wide permissions for managing resources such as Ingress objects, ConfigMaps, and Endpoints.

### Application
- **Deployment (1)**: Deploys the Ingress controller with a single replica by default. The controller is configured with specific settings for traffic management, logging, and metrics.
- **ConfigMap (1)**: Stores configuration settings for the Ingress controller, including options for gzip, Brotli compression, HTTP/2, and logging format.

### Admission Control
- **ValidatingWebhookConfiguration (1)**: Enables admission webhooks for validating Ingress resources.

## Configuration Highlights

Key configuration settings for the `ingress-nginx` component include:

- **Controller Settings**:
  - `admissionWebhooks.enabled`: `true` (enables admission webhooks with a timeout of 30 seconds).
  - `ingressClassResource.name`: `nginx` (sets the name of the ingress class).
  - `ingressClassResource.default`: `true` (sets this ingress class as the default).
  - `terminationGracePeriodSeconds`: `300` (graceful termination period for the controller).
  - `replicaCount`: `1` (number of replicas for the controller).
  - `dnsPolicy`: `ClusterFirstWithHostNet` (DNS policy for the controller).

- **Service Settings**:
  - `type`: `LoadBalancer` (exposes the service externally).
  - `externalTrafficPolicy`: `Local` (preserves the client source IP).
  - `service.annotations`: Configurable annotations for external DNS and load balancer IPs.

- **Logging and Metrics**:
  - `metrics.enabled`: `true` (enables metrics collection).
  - `log-format-upstream`: Custom JSON log format for upstream requests.
  - `enable-gzip` and `enable-brotli`: `true` (enables compression for responses).

- **Custom Configurations**:
  - `use-forwarded-headers`: `true` (enables the use of forwarded headers).
  - `proxy-real-ip-cidr`: Configurable CIDR ranges for trusted proxies.
  - `http-snippet`: Custom NGINX configuration for advanced logging and response time mapping.

## Deployment

- **Target Namespace**: `ingress-nginx`
- **Release Name**: `ingress-nginx`
- **Reconciliation Interval**: `10m`
- **Install Behavior**: Unlimited retries on failure with a timeout of `5m`.
- **Upgrade Behavior**: Automatically retries upgrades and attempts to remediate the last failure.

This deployment is managed by Flux and uses multiple ConfigMaps to provide configuration values, allowing for flexible and dynamic updates. The `ingress-nginx` component is a critical part of the cluster's networking stack, enabling external access to services and providing advanced traffic management capabilities.
