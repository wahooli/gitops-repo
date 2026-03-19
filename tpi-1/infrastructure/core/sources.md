---
title: "sources"
parent: "Infrastructure / Core"
grand_parent: "tpi-1"
---

# Sources

## Overview
The `sources` component is responsible for managing external Helm chart repositories in the `tpi-1` cluster. It uses Flux's `HelmRepository` custom resource to define and synchronize Helm chart repositories, ensuring that the cluster has access to the required charts for deploying and managing applications. This component includes two `HelmRepository` resources.

## Sub-components
This component consists of the following sub-components:

1. **Wahooli Helm Repository**
   - **Chart Repository**: OCI-based repository hosted at `oci://ghcr.io/wahooli/charts`.
   - **Reconciliation Interval**: Every 5 minutes.
   - **Purpose**: Provides access to Helm charts published by Wahooli.

2. **External-DNS Helm Repository**
   - **Chart Repository**: Public repository hosted at `https://kubernetes-sigs.github.io/external-dns/`.
   - **Reconciliation Interval**: Every 24 hours.
   - **Purpose**: Provides access to the `external-dns` Helm chart for managing DNS records dynamically.

## Helm Chart(s)
This component does not directly deploy Helm charts but instead defines the following Helm repositories:

1. **Wahooli**
   - **Repository Type**: OCI
   - **Repository URL**: `oci://ghcr.io/wahooli/charts`
   - **Version**: Latest (floating version)

2. **External-DNS**
   - **Repository Type**: Public HTTP
   - **Repository URL**: `https://kubernetes-sigs.github.io/external-dns/`
   - **Version**: Latest (floating version)

## Resource Glossary
The `sources` component creates the following Kubernetes resources:

1. **HelmRepository (Wahooli)**
   - **Purpose**: Defines an OCI-based Helm chart repository hosted at `ghcr.io`. This repository is synchronized every 5 minutes to ensure the latest charts are available for deployment.
   - **Key Configuration**:
     - `interval`: 5 minutes.
     - `type`: `oci`.
     - `url`: `oci://ghcr.io/wahooli/charts`.

2. **HelmRepository (External-DNS)**
   - **Purpose**: Defines a public Helm chart repository for the `external-dns` project. This repository is synchronized every 24 hours to fetch the latest charts.
   - **Key Configuration**:
     - `interval`: 24 hours.
     - `url`: `https://kubernetes-sigs.github.io/external-dns/`.

## Configuration Highlights
- **Reconciliation Intervals**:
  - Wahooli Helm repository: 5 minutes.
  - External-DNS Helm repository: 24 hours.
- **Repository Types**:
  - Wahooli: OCI-based repository.
  - External-DNS: Public HTTP repository.

## Deployment
- **Target Namespace**: `flux-system`
- **Resource Names**:
  - `wahooli` (HelmRepository)
  - `external-dns` (HelmRepository)
- **Reconciliation Behavior**: 
  - Wahooli repository is reconciled every 5 minutes.
  - External-DNS repository is reconciled every 24 hours.
