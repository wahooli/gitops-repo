---
title: "multus-networks"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

# multus-networks

## Overview

The `multus-networks` component provides additional network interfaces for Kubernetes pods using the Multus CNI plugin. It defines multiple `NetworkAttachmentDefinition` resources that enable pods to connect to specific VLANs using the macvlan CNI plugin. This setup is particularly useful for scenarios requiring advanced networking configurations, such as isolating traffic across different VLANs or integrating with external networks.

This component is deployed in the `livingroom-pi` cluster and managed by Flux.

## Resource Glossary

### Networking Resources

#### NetworkAttachmentDefinition: `vlan90`
- **Namespace**: `default`
- **Purpose**: Provides a network attachment for VLAN 90 using the macvlan CNI plugin.
- **Configuration**:
  - **CNI Version**: `0.3.1`
  - **Type**: `macvlan`
  - **Master Interface**: `eth0.90`
  - **Mode**: `bridge`
  - **IPAM**: Configured to use DHCP for IP address management.

#### NetworkAttachmentDefinition: `vlan100`
- **Namespace**: `default`
- **Purpose**: Provides a network attachment for VLAN 100 using the macvlan CNI plugin.
- **Configuration**:
  - **CNI Version**: `0.3.1`
  - **Type**: `macvlan`
  - **Master Interface**: `eth0.100`
  - **Mode**: `bridge`
  - **IPAM**: Configured to use DHCP for IP address management.

#### NetworkAttachmentDefinition: `vlan110`
- **Namespace**: `default`
- **Purpose**: Provides a network attachment for VLAN 110 using the macvlan CNI plugin.
- **Configuration**:
  - **CNI Version**: `0.3.1`
  - **Type**: `macvlan`
  - **Master Interface**: `eth0.110`
  - **Mode**: `bridge`
  - **IPAM**: Configured to use DHCP for IP address management.

#### NetworkAttachmentDefinition: `vlan200`
- **Namespace**: `default`
- **Purpose**: Provides a network attachment for VLAN 200 using the macvlan CNI plugin.
- **Configuration**:
  - **CNI Version**: `0.3.1`
  - **Type**: `macvlan`
  - **Master Interface**: `eth0.200`
  - **Mode**: `bridge`
  - **IPAM**: Configured to use DHCP for IP address management.

## Configuration Highlights

- **CNI Plugin**: macvlan is used for all network attachments, enabling pods to connect to specific VLANs.
- **IP Address Management**: DHCP is used for dynamic IP allocation, simplifying network configuration.
- **VLAN Integration**: Each `NetworkAttachmentDefinition` is tied to a specific VLAN (90, 100, 110, 200) via the `master` interface.

## Deployment

- **Target Namespace**: `default`
- **Reconciliation**: Managed by Flux through the `infrastructure-platform` Kustomization in the `flux-system` namespace.
- **Install/Upgrade Behavior**: Changes to the `NetworkAttachmentDefinition` resources are automatically reconciled by Flux.
