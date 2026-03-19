---
title: "kube-dns"
parent: "Infrastructure / Kube-dns"
grand_parent: "tpi-1"
---

# kube-dns

## Overview

The `kube-dns` component provides DNS resolution services for the Kubernetes cluster `tpi-1`. It is implemented using CoreDNS, a flexible and extensible DNS server designed specifically for cloud-native environments. This component ensures that services and pods within the cluster can resolve DNS queries efficiently, enabling seamless communication between workloads.

## Helm Chart(s)

This component is deployed using a Kustomize-based configuration and does not rely on a Helm chart.

## Resource Glossary

### Networking

- **Service: kube-dns-tpi**
  - **Type:** `ClusterIP`
  - **Purpose:** Provides DNS resolution for cluster-internal traffic. It listens on port 53 for both UDP and TCP protocols and forwards requests to the `coredns` pods.
  - **Annotations:**
    - `service.cilium.io/affinity: local`: Ensures the service is routed locally within the node.
    - `service.cilium.io/global: "true"`: Makes the service globally available across the cluster.
  - **Selector:** Targets pods with the label `k8s-app: kube-dns`.

- **Service: kube-dns-nas**
  - **Type:** `ClusterIP` (headless service with `clusterIP: null`)
  - **Purpose:** Provides DNS resolution for specific use cases requiring a headless service. It listens on port 53 for both UDP and TCP protocols and forwards requests to the `coredns` pods.
  - **Annotations:**
    - `service.cilium.io/global: "true"`: Makes the service globally available across the cluster.

### Workloads

- **Deployment: coredns**
  - **Replicas:** 4
  - **Purpose:** Runs the CoreDNS pods that handle DNS resolution for the cluster.
  - **Pod Affinity:** Configured with `podAntiAffinity` to distribute pods across different nodes for high availability.
  - **Container: coredns**
    - **Image:** `coredns/coredns:1.11.3`
    - **Args:** Configured to use a custom Corefile located at `/etc/coredns/override/Corefile`.
    - **Volume Mounts:** Mounts a ConfigMap (`coredns-79df22892t`) at `/etc/coredns/override` for custom configuration.

### Configuration

- **ConfigMap: coredns-79df22892t**
  - **Purpose:** Provides the custom Corefile configuration for CoreDNS.
  - **Key Configuration:**
    - DNS queries are resolved using the `kubernetes` plugin for service and pod DNS names.
    - The `hosts` plugin is used to resolve entries from a file (`/etc/coredns/NodeHosts`) with a TTL of 60 seconds.
    - The `prometheus` plugin is enabled on port 9153 for metrics collection.
    - DNS caching is configured with a success cache size of 9984 and a denial cache size of 9984.
    - The `rewrite` plugin is used to set EDNS0 subnet information.
    - The `template` plugin is configured to respond to `ANY` queries with `NOERROR`.
    - Queries are forwarded to `/etc/resolv.conf` for external resolution.

## Configuration Highlights

- **Replica Count:** The `coredns` deployment is configured with 4 replicas to ensure high availability and load balancing.
- **Pod Anti-Affinity:** Pods are distributed across nodes to improve resilience and reduce the risk of downtime.
- **Custom Corefile Configuration:** The Corefile is tailored to the cluster's needs, including plugins for health checks, metrics, caching, and DNS forwarding.
- **Image Version:** The `coredns` container uses the exact version `1.11.3` of the `coredns/coredns` image.

## Deployment

- **Target Namespace:** `kube-system`
- **Release Name:** `infrastructure-kube-dns`
- **Reconciliation Behavior:** Managed by Flux with Kustomize. The deployment is configured with `kustomize.toolkit.fluxcd.io/ssa: merge` for server-side apply and `kustomize.toolkit.fluxcd.io/prune: disabled` to prevent resource pruning.
