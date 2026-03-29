---
title: "cilium"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# Cilium

## Overview

Cilium is a high-performance networking, security, and load balancing solution for Kubernetes environments. In the `tpi-1` cluster, Cilium is configured to provide advanced networking features such as BGP-based routing, load balancer IP management, and integration with external systems via BGP peering. This deployment leverages custom resources to manage BGP advertisements, BGP cluster configurations, and load balancer IP pools.

## Resource Glossary

### Networking

1. **CiliumBGPAdvertisement (`bgp-advertisements`)**  
   - Advertises Kubernetes services over BGP.  
   - Configured to advertise services with a `LoadBalancerIP` address, excluding services with the label `disable-advertisement: true`.

2. **CiliumBGPClusterConfig (`cilium-bgp`)**  
   - Defines the BGP cluster configuration for the Kubernetes cluster.  
   - Configures a BGP instance named `cluster-instance` with two peers:  
     - **breakout**: Configured with `peerASN` `${breakout_bgp_peer_as}` and `peerAddress` `${breakout_bgp_peer_ip}`.  
     - **quantum**: Configured with `peerASN` `${quantum_bgp_peer_as}` and `peerAddress` `${quantum_bgp_peer_ip}`.  
   - Both peers reference the `tor-peer` configuration for additional settings.  
   - Nodes with the label `exclude-from-peering: true` are excluded from the BGP cluster.

3. **CiliumBGPPeerConfig (`tor-peer`)**  
   - Defines the configuration for BGP peers.  
   - Supports IPv4 unicast advertisements with the label `advertise: bgp`.  
   - Enables graceful restart with a restart time of 15 seconds.  
   - Configures BGP timers:  
     - Hold time: 90 seconds.  
     - Keepalive time: 30 seconds.

### Load Balancer IP Management

1. **CiliumLoadBalancerIPPool (`lb-pool`)**  
   - Manages a pool of IP addresses for load balancers.  
   - The CIDR range is defined by the `${cluster_bgp_lb_pool}` variable.  
   - Does not allow the use of the first and last IPs in the range.

2. **CiliumLoadBalancerIPPool (`internal-dns-ip-pool`)**  
   - Manages a pool of IP addresses for internal DNS services.  
   - Includes specific IP addresses: `${dns_ip_addr_1}`, `${dns_ip_addr_2}`, `${dns_ip_addr_3}`, `8.8.8.8`, and `8.8.4.4`.  
   - Applies to services in the `internal-dns` namespace.

3. **CiliumLoadBalancerIPPool (`envoy-gateway-ip-pool`)**  
   - Manages a pool of IP addresses for the Envoy Gateway.  
   - Includes specific IP addresses: `${envoy_gw_lb_ip}` and `${envoy_gw_private_lb_ip}`.  
   - Applies to services in the `envoy-gateway-system` namespace.

## Configuration Highlights

- **BGP Peering**:  
  - Two BGP peers (`breakout` and `quantum`) are configured with specific Autonomous System Numbers (ASNs) and IP addresses.  
  - Graceful restart is enabled for BGP peers, ensuring minimal disruption during restarts.  

- **Load Balancer IP Pools**:  
  - Multiple IP pools are defined for different purposes (general load balancers, internal DNS, and Envoy Gateway).  
  - IP pools are tightly scoped using service selectors and specific IP ranges.

- **Node Selection**:  
  - Nodes labeled with `exclude-from-peering: true` are excluded from participating in the BGP cluster.

## Deployment

- **Target Namespace**: The resources are deployed in the `flux-system` namespace.  
- **Reconciliation**: Managed by Flux with the `infrastructure-core` Kustomize overlay.  
- **Configurable Parameters**:  
  - `${cluster_bgp_as_number}`: Local ASN for the BGP cluster.  
  - `${breakout_bgp_peer_as}` and `${breakout_bgp_peer_ip}`: ASN and IP address for the `breakout` peer.  
  - `${quantum_bgp_peer_as}` and `${quantum_bgp_peer_ip}`: ASN and IP address for the `quantum` peer.  
  - `${cluster_bgp_lb_pool}`: CIDR range for the load balancer IP pool.  
  - `${dns_ip_addr_1}`, `${dns_ip_addr_2}`, `${dns_ip_addr_3}`: IP addresses for internal DNS.  
  - `${envoy_gw_lb_ip}` and `${envoy_gw_private_lb_ip}`: IP addresses for the Envoy Gateway.
