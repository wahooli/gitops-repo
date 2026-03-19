---
title: "cilium"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# Cilium

## Overview

Cilium is a networking and security solution for Kubernetes, providing advanced networking features such as eBPF-based networking, load balancing, and network policies. In this deployment, Cilium is configured to manage BGP (Border Gateway Protocol) advertisements and load balancer IP pools for the `nas` cluster. This setup enables efficient routing and IP management for services within the cluster.

## Resource Glossary

### Networking

1. **CiliumBGPAdvertisement (`bgp-advertisements`)**  
   - Advertises Kubernetes services over BGP.  
   - Configured to advertise services with the `disable-advertisement` label set to anything other than `"true"`.  
   - Advertises `LoadBalancerIP` addresses for services.

2. **CiliumBGPClusterConfig (`cilium-bgp`)**  
   - Configures BGP instances for the cluster.  
   - Defines a BGP instance named `cluster-instance` with two peers:  
     - **breakout**: Configured with `peerASN` `${breakout_bgp_peer_as}` and `peerAddress` `${breakout_bgp_peer_ip}`.  
     - **quantum**: Configured with `peerASN` `${quantum_bgp_peer_as}` and `peerAddress` `${quantum_bgp_peer_ip}`.  
   - Both peers reference the `tor-peer` configuration for additional settings.  
   - Nodes with the label `exclude-from-peering: "true"` are excluded from BGP peering.

3. **CiliumBGPPeerConfig (`tor-peer`)**  
   - Defines BGP peer configuration for the cluster.  
   - Advertises IPv4 unicast routes with labels matching `advertise: bgp`.  
   - Enables graceful restart with a restart time of 15 seconds.  
   - Configures BGP timers:  
     - Hold time: 90 seconds.  
     - Keepalive time: 30 seconds.

4. **CiliumLoadBalancerIPPool (`internal-dns-ip-pool`)**  
   - Manages a pool of IP addresses for internal DNS services.  
   - Defines specific IP blocks:  
     - `${dns_ip_addr_1}`, `${dns_ip_addr_2}`, `${dns_ip_addr_3}`, `8.8.8.8`, and `8.8.4.4`.  
   - Applies to services in the `internal-dns` namespace.

5. **CiliumLoadBalancerIPPool (`lb-pool`)**  
   - Manages a pool of IP addresses for load balancers in the cluster.  
   - Configured with a CIDR block defined by `${cluster_bgp_lb_pool}`.  
   - Disallows the use of the first and last IPs in the range.

## Configuration Highlights

- **BGP Configuration**:  
  - The cluster uses BGP for service advertisement and routing.  
  - BGP peers are defined dynamically using Flux variables (`${breakout_bgp_peer_as}`, `${breakout_bgp_peer_ip}`, `${quantum_bgp_peer_as}`, `${quantum_bgp_peer_ip}`).  
  - Graceful restart is enabled for BGP peers to ensure minimal disruption during restarts.

- **Load Balancer IP Pools**:  
  - Two IP pools are defined:  
    - `internal-dns-ip-pool` for internal DNS services.  
    - `lb-pool` for general load balancer services.  
  - IP ranges for these pools are configurable using Flux variables (`${dns_ip_addr_1}`, `${dns_ip_addr_2}`, `${dns_ip_addr_3}`, `${cluster_bgp_lb_pool}`).

## Deployment

- **Target Namespace**: `flux-system`  
- **Reconciliation Interval**: Managed by Flux, as per the `infrastructure-platform` Kustomization.  
- **Install/Upgrade Behavior**: Changes to the configuration are automatically applied by Flux based on the GitOps workflow.  

This deployment uses Flux variables (`${variable_name}`) for dynamic configuration, allowing customization of BGP and IP pool settings based on the cluster's requirements. Ensure these variables are defined in the appropriate Flux configuration files before deploying.
