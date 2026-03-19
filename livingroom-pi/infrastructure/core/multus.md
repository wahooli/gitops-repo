---
title: "multus"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# Multus

## Overview
The `multus` component integrates the Multus CNI (Container Network Interface) plugin into the Kubernetes cluster. Multus enables the attachment of multiple network interfaces to pods, allowing for advanced networking configurations such as connecting pods to multiple networks. This is particularly useful for scenarios requiring network isolation, high-performance networking, or integration with external network resources.

In this deployment, the Multus CNI plugin is managed via Flux using a GitRepository and Kustomization. The configuration is sourced from the official Multus GitHub repository.

## Helm Chart(s)
This component does not use Helm charts. Instead, it is deployed using Kustomize to apply a pre-defined DaemonSet manifest from the Multus GitHub repository.

## Resource Glossary
The following Kubernetes resources are created by this component:

### Networking
- **DaemonSet (`multus-daemonset`)**:  
  The DaemonSet deploys the Multus CNI plugin on all cluster nodes. This ensures that every node is equipped with the necessary components to support multiple network interfaces for pods. The DaemonSet runs a pod on each node, which installs and manages the Multus CNI binary and configuration.

### Configuration Management
- **GitRepository (`multus-git`)**:  
  This resource points to the official Multus GitHub repository (`https://github.com/k8snetworkplumbingwg/multus-cni.git`) and fetches the configuration files required for deploying the Multus DaemonSet. It is configured to pull updates from the `v4.1.4` tag every 48 hours.

- **Kustomization (`multus`)**:  
  The Kustomization resource applies the Multus DaemonSet manifest located in the `deployments` directory of the GitRepository. It ensures that the deployment is reconciled every 24 hours and prunes any resources that are no longer defined in the source.

## Configuration Highlights
- **GitRepository Configuration**:  
  - Repository URL: `https://github.com/k8snetworkplumbingwg/multus-cni.git`  
  - Reference: `v4.1.4` tag  
  - Sync Interval: Every 48 hours  
  - Ignore Rules: All files are ignored except for `deployments/multus-daemonset.yml`.

- **Kustomization Configuration**:  
  - Path: `./deployments`  
  - Reconciliation Interval: Every 24 hours  
  - Prune: Enabled (removes resources not defined in the source)  
  - Wait: Enabled (ensures resources are fully reconciled before marking the deployment as successful).

## Deployment
- **Target Namespace**: `flux-system`  
- **GitRepository Name**: `multus-git`  
- **Kustomization Name**: `multus`  
- **Reconciliation Interval**:  
  - GitRepository: 48 hours  
  - Kustomization: 24 hours  
- **Install/Upgrade Behavior**:  
  The deployment uses Kustomize to apply the Multus DaemonSet manifest. Changes to the `v4.1.4` tag in the GitRepository are automatically reconciled by Flux.
