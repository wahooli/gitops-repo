---
title: "sources"
parent: "Infrastructure / Core"
grand_parent: "nas"
---

# Sources

## Overview
The `sources` component is responsible for managing Helm chart repositories used by the Flux GitOps system in the `nas` cluster. It defines two `HelmRepository` resources, which enable Flux to fetch and reconcile Helm charts from specified repositories. These repositories provide the source for deploying various workloads and services in the cluster.

## Sub-components
This component includes two Helm repositories:

1. **wahooli**: An OCI-based Helm repository hosted on GitHub Container Registry (GHCR). It is used to source charts from the `ghcr.io/wahooli/charts` repository.
2. **external-dns**: A public Helm repository hosted at `https://kubernetes-sigs.github.io/external-dns/`. It provides charts for the ExternalDNS project.

## Helm Chart(s)
This component does not directly deploy any Helm charts but defines the following Helm repositories:

1. **wahooli**
   - **Repository Type**: OCI
   - **URL**: `oci://ghcr.io/wahooli/charts`
   - **Version**: latest (floating version)

2. **external-dns**
   - **Repository Type**: Public
   - **URL**: `https://kubernetes-sigs.github.io/external-dns/`
   - **Version**: latest (floating version)

## Resource Glossary
The `sources` component creates the following Kubernetes resources:

1. **HelmRepository: wahooli**
   - **Purpose**: Defines an OCI-based Helm repository for fetching charts from `ghcr.io/wahooli/charts`.
   - **Reconciliation Interval**: Every 5 minutes.
   - **Namespace**: `flux-system`.

2. **HelmRepository: external-dns**
   - **Purpose**: Defines a public Helm repository for fetching charts related to the ExternalDNS project.
   - **Reconciliation Interval**: Every 24 hours.
   - **Namespace**: `flux-system`.

These resources ensure that the Flux system can continuously monitor and fetch updates from the specified Helm repositories.

## Configuration Highlights
- **Reconciliation Intervals**:
  - `wahooli`: 5 minutes.
  - `external-dns`: 24 hours.
- **Repository Types**:
  - `wahooli`: OCI-based repository.
  - `external-dns`: Public HTTP-based repository.

## Deployment
- **Target Namespace**: `flux-system`
- **Reconciliation Intervals**:
  - `wahooli`: 5 minutes.
  - `external-dns`: 24 hours.
- **Install/Upgrade Behavior**: Managed by Flux's reconciliation loop, which ensures that the Helm repositories are always up-to-date with their respective sources.
