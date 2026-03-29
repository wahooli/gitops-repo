---
title: "cilium"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# Cilium

## Overview

Cilium is a networking and security solution for Kubernetes clusters, providing advanced networking features such as eBPF-based networking, load balancing, and security policies. In this deployment, Cilium is configured with BGP (Border Gateway Protocol) capabilities to enable advanced routing and load balancing for services. This component also manages IP pools for load balancers and specific services.

## Helm Chart(s)

This deployment does not use Helm charts directly. Instead, it is managed via Flux with Kustomize-rendered manifests.

## Resource Glossary

### Networking Resources

1. **CiliumBGPAdvertisement** (`bgp-advertisements`):
   - Advertises Kubernetes services over BGP.
   - Configured to advertise services with the `LoadBalancerIP` address type, excluding those with the label `disable-advertisement: true`.

2. **CiliumBGPClusterConfig** (`cilium-bgp`):
   - Defines the BGP configuration for the cluster.
   - Configures BGP instances with peers for routing traffic:
     - `breakout` peer with ASN `${breakout_bgp_peer_as}` and IP `${breakout_bgp_peer_ip}`.
     - `quantum` peer with ASN `${quantum_bgp_peer_as}` and IP `${quantum_bgp_peer_ip}`.
   - Uses a node selector to exclude nodes labeled with `exclude-from-peering: true`.

3. **CiliumBGPPeerConfig** (`tor-peer`):
   - Specifies BGP peer configurations, including:
     - IPv4 unicast address family.
     - Graceful restart enabled with a restart time of 15 seconds.
     - Timers for hold time (90 seconds) and keep-alive (30 seconds).

4. **CiliumLoadBalancerIPPool**:
   - **`lb-pool`**:
     - Defines a pool of IP addresses for load balancers.
     - CIDR range is configurable via `${cluster_bgp_lb_pool}`.
     - Does not allow the use of the first and last IPs in the range.
   - **`internal-dns-ip-pool`**:
     - Defines IP addresses for internal DNS services.
     - Includes specific IPs (`${dns_ip_addr_1}`, `${dns_ip_addr_2}`, `${dns_ip_addr_3}`, `8.8.8.8`, `8.8.4.4`).
     - Applies to services in the `internal-dns` namespace.
   - **`envoy-gateway-ip-pool`**:
     - Defines IP addresses for the Envoy Gateway.
     - Includes specific IPs (`${envoy_gw_lb_ip}`, `${envoy_gw_private_lb_ip}`).
     - Applies to services in the `envoy-gateway-system` namespace.

## Configuration Highlights

- **BGP Configuration**:
  - Local ASN: `${cluster_bgp_as_number}`.
  - Peer configurations for `breakout` and `quantum` with ASNs and IPs defined via Flux variables.
  - Graceful restart enabled with a 15-second restart time.

- **Load Balancer IP Pools**:
  - Configurable CIDR range for the main load balancer pool.
  - Specific IPs allocated for internal DNS and Envoy Gateway services.

- **Service Advertisement**:
  - Services with `LoadBalancerIP` addresses are advertised over BGP.
  - Services with the label `disable-advertisement: true` are excluded.

## Deployment

- **Target Namespace**: `flux-system`
- **Release Name**: `infrastructure-core`
- **Reconciliation Interval**: Managed by Flux, based on the Kustomize configuration.
- **Install/Upgrade Behavior**: Controlled by Flux's GitOps workflow, ensuring automated deployment and updates based on the repository state. 

### Configurable Parameters

The following parameters are configurable via Flux variables:

- `${cluster_bgp_as_number}`: Local ASN for the cluster.
- `${breakout_bgp_peer_as}`: ASN for the `breakout` BGP peer.
- `${breakout_bgp_peer_ip}`: IP address for the `breakout` BGP peer.
- `${quantum_bgp_peer_as}`: ASN for the `quantum` BGP peer.
- `${quantum_bgp_peer_ip}`: IP address for the `quantum` BGP peer.
- `${cluster_bgp_lb_pool}`: CIDR range for the load balancer IP pool.
- `${dns_ip_addr_1}`, `${dns_ip_addr_2}`, `${dns_ip_addr_3}`: IPs for the internal DNS service.
- `${envoy_gw_lb_ip}`, `${envoy_gw_private_lb_ip}`: IPs for the Envoy Gateway load balancer.
