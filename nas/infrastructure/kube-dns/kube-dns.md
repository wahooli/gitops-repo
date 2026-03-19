---
title: "kube-dns"
parent: "Infrastructure / Kube-dns"
grand_parent: "nas"
---

# kube-dns

## Overview
The `kube-dns` component provides DNS resolution services within the Kubernetes cluster. It is implemented using CoreDNS, a flexible and extensible DNS server designed for service discovery and name resolution in containerized environments. This component is essential for internal DNS resolution, enabling Kubernetes workloads to communicate with each other using DNS names.

## Resource Glossary

### Networking
- **Service: `kube-dns-tpi`**
  - Type: `ClusterIP`
  - Ports:
    - `dns` (UDP): Port 53 for DNS queries over UDP.
    - `dns-tcp` (TCP): Port 53 for DNS queries over TCP.
  - Internal Traffic Policy: `Cluster`
  - Annotation: `service.cilium.io/global: "true"` indicates that the service is globally accessible across the cluster.

- **Service: `kube-dns-nas`**
  - Type: `ClusterIP`
  - Ports:
    - `dns` (UDP): Port 53 for DNS queries over UDP.
    - `dns-tcp` (TCP): Port 53 for DNS queries over TCP.
  - Internal Traffic Policy: `Cluster`
  - Selector: Targets pods with the label `k8s-app: kube-dns`.
  - Annotation: 
    - `service.cilium.io/global: "true"` indicates global accessibility.
    - `service.cilium.io/affinity: local` ensures local affinity for traffic routing.

### Workload
- **Deployment: `coredns`**
  - Namespace: `kube-system`
  - Replicas: `1`
  - Pod Anti-Affinity: Ensures that CoreDNS pods are distributed across nodes to improve availability.
  - Container: `coredns`
    - Image: `coredns/coredns:1.11.3`
    - Arguments: `-conf /etc/coredns/override/Corefile` specifies the configuration file for CoreDNS.
    - Volume Mounts: Mounts the `config-override` volume at `/etc/coredns/override` for custom configuration.
  - Volume: `config-override`
    - Type: ConfigMap
    - ConfigMap Name: `coredns-79df22892t`

### Configuration
- **ConfigMap: `coredns-79df22892t`**
  - Namespace: `kube-system`
  - Contains the CoreDNS configuration (`Corefile`), which defines DNS behavior:
    - Handles DNS queries for `cluster.local` and reverse DNS zones (`in-addr.arpa`, `ip6.arpa`).
    - Uses a `hosts` file for node host resolution.
    - Enables metrics collection via Prometheus on port `9153`.
    - Implements caching for DNS responses.
    - Configures EDNS0 subnet rewriting and load balancing.

## Configuration Highlights
- **Pod Anti-Affinity**: Ensures CoreDNS pods are distributed across nodes for high availability.
- **CoreDNS Image**: `coredns/coredns:1.11.3` is used, providing a stable and feature-rich DNS server.
- **Custom Configuration**: The `Corefile` is mounted from a ConfigMap, allowing flexible DNS behavior customization.
- **Replica Count**: Set to `1` for this deployment, suitable for small clusters. Larger clusters may require scaling.

## Deployment
- **Target Namespace**: `kube-system`
- **Release Name**: `kube-dns`
- **Reconciliation Behavior**: Managed by Flux with annotations indicating pruning is disabled and server-side apply (SSA) is used for updates.

This component is critical for maintaining DNS resolution within the cluster, ensuring seamless communication between workloads.
