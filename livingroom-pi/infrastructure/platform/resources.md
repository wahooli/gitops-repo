---
title: "platform resources"
parent: "Infrastructure / Platform"
grand_parent: "livingroom-pi"
---

## Overview

The `ci-excluded` resource in the `platform` infrastructure layer for the `livingroom-pi` cluster is a Flux Kustomization. It is responsible for managing a specific subset of Kubernetes manifests located in the `./infrastructure/ci-excluded/livingroom-pi` directory of the Git repository. This Kustomization ensures that the specified resources are applied to the cluster, kept up to date, and pruned when no longer needed. It also supports dynamic configuration through variable substitution using secrets.

## Resource Glossary

### Kustomization: `ci-excluded`
- **Kind**: `Kustomization`
- **Name**: `ci-excluded`
- **Namespace**: `flux-system`
- **Purpose**: This resource defines a Flux Kustomization that applies and manages Kubernetes manifests for the `ci-excluded` component of the `platform` infrastructure layer in the `livingroom-pi` cluster.
- **Functionality**:
  - Synchronizes the manifests located at `./infrastructure/ci-excluded/livingroom-pi` in the Git repository with the cluster every 5 minutes.
  - Ensures that any resources defined in the specified path are applied to the cluster and removes resources that are no longer defined (pruning).
  - Dynamically substitutes variables in the manifests using values from the following secrets:
    - `cluster-infrastructure-vars` (required)
    - `dns-vars` (optional)
    - `cluster-vars` (optional)
- **Source Reference**: The manifests are sourced from the `flux-system` GitRepository resource.
