---
title: "node-local-dns"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# node-local-dns

## Overview

The `node-local-dns` component provides a local DNS caching service for Kubernetes nodes in the `livingroom-pi` cluster. It improves DNS query performance by reducing latency and offloading DNS traffic from the cluster DNS service. This component runs as a DaemonSet, ensuring that the DNS caching service is deployed on every node in the cluster. It uses the `k8s-dns-node-cache` image to provide DNS caching functionality.

## Resource Glossary

### Networking Resources
- **Service (`kube-dns-upstream`)**:  
  A ClusterIP service that forwards DNS queries to the upstream DNS resolver. It listens on port 53 for both UDP and TCP traffic. This service is used by the `node-local-dns` DaemonSet to forward DNS queries.

### Workload Resources
- **DaemonSet (`node-local-dns`)**:  
  Deploys the DNS caching service on every node in the cluster. The DaemonSet runs a container using the `k8s-dns-node-cache:1.15.16` image. The container listens on port 53 for DNS queries (both UDP and TCP) and port 9253 for metrics. It uses a `ConfigMap` to configure the DNS caching behavior and forwards queries to the upstream DNS resolver.

### Configuration Resources
- **ConfigMap (`node-local-dns-tgk9hht8t7`)**:  
  Contains the CoreDNS configuration for the `node-local-dns` service. It defines DNS caching rules, upstream DNS servers, and metrics collection settings. The configuration includes support for multiple DNS zones, such as `cluster.local`, `nas.local`, and reverse DNS zones (`in-addr.arpa` and `ip6.arpa`).

### Security Resources
- **ServiceAccount (`node-local-dns`)**:  
  Provides the necessary permissions for the `node-local-dns` DaemonSet to operate securely within the `kube-system` namespace.

## Configuration Highlights

- **Image**: `registry.k8s.io/dns/k8s-dns-node-cache:1.15.16`
- **Resource Requests**:  
  - CPU: `25m`  
  - Memory: `5Mi`  
- **Ports**:  
  - `53/UDP` and `53/TCP` for DNS queries  
  - `9253/TCP` for metrics  
- **Priority Class**: `system-node-critical` ensures high priority for scheduling.  
- **Tolerations**: Allows the DaemonSet to run on nodes with taints for critical system components.  
- **Annotations**:  
  - `policy.cilium.io/no-track-port: "53"`: Ensures that port 53 traffic is not tracked by Cilium.  
  - `prometheus.io/scrape: "true"` and `prometheus.io/port: "9253"`: Enable Prometheus metrics scraping on port 9253.  

## Deployment

- **Target Namespace**: `kube-system`  
- **Release Name**: Not explicitly defined in the manifests; managed by Flux under the `infrastructure-platform` kustomization.  
- **Reconciliation Interval**: Defined by FluxCD's default behavior for the `infrastructure-platform` kustomization.  
- **Install/Upgrade Behavior**: Rolling updates are configured for the DaemonSet with a maximum of 10% unavailable pods during updates.

## Notes

- The component uses Flux variables (`${cluster_dns_ip}`, `${nas_cluster_domain}`, `${cluster_domain}`) for dynamic configuration. These variables should be set appropriately in the FluxCD environment to ensure correct DNS behavior.
- The DNS caching service is optimized for performance with caching settings that reduce latency and improve query efficiency.
- Metrics are exposed on port 9253 for monitoring DNS performance and health using Prometheus.
