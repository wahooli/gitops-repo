---
title: "cilium"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# Cilium

## Overview

Cilium is a networking and security solution for Kubernetes, providing advanced networking features such as eBPF-based load balancing, network policies, and observability. In the `tpi-1` cluster, Cilium is configured to support BGP-based routing, load balancer IP management, and local DNS redirection. This deployment leverages custom Cilium resources to enable these features.

## Resource Glossary

### Networking

1. **CiliumBGPAdvertisement (`bgp-advertisements`)**
   - Advertises Kubernetes services over BGP.
   - Configured to advertise services of type `LoadBalancer` unless they are explicitly labeled with `disable-advertisement: "true"`.

2. **CiliumBGPClusterConfig (`cilium-bgp`)**
   - Defines the BGP configuration for the cluster.
   - Includes BGP instances with local ASN (`${cluster_bgp_as_number}`) and peers:
     - `breakout`: Peer ASN `${breakout_bgp_peer_as}`, Peer IP `${breakout_bgp_peer_ip}`, Peer Config Reference `tor-peer`.
     - `quantum`: Peer ASN `${quantum_bgp_peer_as}`, Peer IP `${quantum_bgp_peer_ip}`, Peer Config Reference `tor-peer`.
   - Applies to nodes not labeled with `exclude-from-peering: "true"`.

3. **CiliumBGPPeerConfig (`tor-peer`)**
   - Configures BGP peer settings for peers referenced in `CiliumBGPClusterConfig`.
   - Supports IPv4 unicast (`afi: ipv4`, `safi: unicast`) with graceful restart enabled (15 seconds restart time).
   - Timers: Hold time of 90 seconds and keep-alive interval of 30 seconds.

4. **CiliumLoadBalancerIPPool**
   - **`internal-dns-ip-pool`**:
     - Manages a pool of IP addresses for internal DNS services.
     - Includes specific IP addresses (`${dns_ip_addr_1}`, `${dns_ip_addr_2}`, `${dns_ip_addr_3}`, `8.8.8.8`, `8.8.4.4`).
     - Applies to services in the `internal-dns` namespace.
   - **`lb-pool`**:
     - Manages a pool of IP addresses for load balancers.
     - Configured with a CIDR block (`${cluster_bgp_lb_pool}`).
     - Does not allow the use of the first and last IPs in the CIDR block.

5. **CiliumLocalRedirectPolicy (`nodelocaldns`)**
   - Redirects DNS traffic to local endpoints for improved performance and reliability.
   - Matches the `kube-dns` service in the `kube-system` namespace.
   - Redirects traffic to ports `53` (UDP and TCP) on endpoints labeled with `app.kubernetes.io/instance: kube-dns`.

## Configuration Highlights

- **BGP Configuration**:
  - Local ASN and peer ASNs are parameterized (`${cluster_bgp_as_number}`, `${breakout_bgp_peer_as}`, `${quantum_bgp_peer_as}`).
  - Peer IPs are also parameterized (`${breakout_bgp_peer_ip}`, `${quantum_bgp_peer_ip}`).
  - Graceful restart and custom timers are configured for BGP peers.

- **Load Balancer IP Pools**:
  - Two distinct IP pools are defined:
    - `internal-dns-ip-pool`: For internal DNS services.
    - `lb-pool`: For general load balancer usage, with restrictions on the first and last IPs in the CIDR block.

- **Local DNS Redirection**:
  - Redirects DNS traffic to local `kube-dns` endpoints for improved resolution performance.

## Deployment

- **Target Namespace**: Resources are deployed across multiple namespaces:
  - `kube-system` for the `CiliumLocalRedirectPolicy`.
  - Cluster-wide for other Cilium resources.
- **Reconciliation**: Managed by Flux with the `infrastructure-platform` kustomization in the `flux-system` namespace.
- **Configurable Parameters**: The deployment includes several parameterized values (e.g., `${cluster_bgp_as_number}`, `${breakout_bgp_peer_as}`, `${dns_ip_addr_1}`), which can be customized based on the cluster's requirements.
