---
title: "sources"
parent: "Infrastructure / Core"
grand_parent: "livingroom-pi"
---

# Sources

## Overview
The `sources` component is responsible for managing Helm chart repositories within the `livingroom-pi` cluster. It defines and synchronizes external Helm repositories, enabling other Flux components to fetch and deploy Helm charts from these sources. This component ensures that the cluster has access to the latest or specified versions of Helm charts from the configured repositories.

## Helm Chart(s)
This component does not deploy any Helm charts directly. Instead, it defines the following Helm repositories:

1. **Wahooli Helm Repository**
   - **Repository Type**: OCI
   - **URL**: `oci://ghcr.io/wahooli/charts`
   - **Version**: `latest` (floating version)
   - **Reconciliation Interval**: Every 5 minutes

2. **External-DNS Helm Repository**
   - **Repository Type**: HTTP
   - **URL**: `https://kubernetes-sigs.github.io/external-dns/`
   - **Version**: Exact versions are defined in dependent HelmReleases.
   - **Reconciliation Interval**: Every 24 hours

## Resource Glossary
The `sources` component creates the following Kubernetes resources:

### Networking
- **HelmRepository (wahooli)**: 
  - Represents an OCI-based Helm repository hosted at `ghcr.io/wahooli/charts`. 
  - Configured to synchronize every 5 minutes to ensure the latest charts are available for deployment.
  
- **HelmRepository (external-dns)**:
  - Represents an HTTP-based Helm repository hosted at `https://kubernetes-sigs.github.io/external-dns/`.
  - Configured to synchronize every 24 hours to fetch updates to the External-DNS Helm chart.

These resources allow Flux to fetch Helm charts from external sources and make them available for deployment in the cluster.

## Configuration Highlights
- **Reconciliation Intervals**:
  - Wahooli Helm Repository: 5 minutes
  - External-DNS Helm Repository: 24 hours
- **Repository Types**:
  - Wahooli: OCI-based repository
  - External-DNS: HTTP-based repository

## Deployment
- **Target Namespace**: `flux-system`
- **Resource Names**: 
  - `wahooli` (HelmRepository)
  - `external-dns` (HelmRepository)
- **Reconciliation Behavior**: 
  - Wahooli repository is reconciled every 5 minutes.
  - External-DNS repository is reconciled every 24 hours.

This component is managed by Flux and is part of the `infrastructure-core` Kustomization in the `flux-system` namespace.
