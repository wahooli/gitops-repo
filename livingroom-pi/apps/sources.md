---
title: "sources"
parent: "Apps"
grand_parent: "livingroom-pi"
---

# Sources

## Overview
The `sources` component is responsible for managing external Helm chart repositories in the `livingroom-pi` cluster. It defines and synchronizes Helm repositories, enabling other components to fetch and deploy Helm charts from these sources. This component ensures that the cluster has access to the latest versions of charts from specified repositories.

## Helm Chart(s)
This component does not deploy any Helm charts directly. Instead, it defines two `HelmRepository` resources that point to external Helm chart repositories:

1. **Bitnami Helm Repository**
   - **Repository URL**: `https://charts.bitnami.com/bitnami`
   - **Reconciliation Interval**: 24 hours

2. **Bitnami OCI Helm Repository**
   - **Repository URL**: `oci://registry-1.docker.io/bitnamicharts`
   - **Type**: OCI
   - **Reconciliation Interval**: 24 hours

## Resource Glossary
The `sources` component creates the following Kubernetes resources:

### HelmRepository
1. **bitnami**
   - **Purpose**: Provides access to the Bitnami Helm chart repository hosted at `https://charts.bitnami.com/bitnami`.
   - **Reconciliation Interval**: The repository is synchronized every 24 hours to fetch the latest chart metadata.
   - **Namespace**: `flux-system`

2. **bitnami-oci**
   - **Purpose**: Provides access to the Bitnami OCI-based Helm chart repository hosted at `oci://registry-1.docker.io/bitnamicharts`.
   - **Reconciliation Interval**: The repository is synchronized every 24 hours to fetch the latest chart metadata.
   - **Namespace**: `flux-system`

These resources enable other components in the cluster to reference and deploy charts from the specified repositories.

## Configuration Highlights
- **Reconciliation Interval**: Both Helm repositories are configured to synchronize with their respective sources every 24 hours. This ensures that the cluster has up-to-date metadata for the available charts.
- **Repository Types**: 
  - The `bitnami` repository uses a standard HTTP(S) URL for fetching charts.
  - The `bitnami-oci` repository uses the OCI protocol for accessing container-based Helm charts.

## Deployment
- **Target Namespace**: `flux-system`
- **Reconciliation Interval**: 24 hours
- **Install/Upgrade Behavior**: The `HelmRepository` resources are managed by Flux and will be reconciled automatically based on the specified interval. Any changes to the repository configuration will be applied during the next reconciliation cycle.
