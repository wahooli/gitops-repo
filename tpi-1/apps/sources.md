---
title: "sources"
parent: "Apps"
grand_parent: "tpi-1"
---

# Sources

## Overview
The `sources` component is responsible for managing external Helm chart repositories in the `tpi-1` cluster. It defines two `HelmRepository` resources, enabling Flux to fetch and reconcile Helm charts from both a public HTTP-based repository and an OCI-based repository. This component plays a critical role in providing access to external Helm charts for other workloads in the cluster.

## Helm Chart(s)
This component does not deploy any Helm charts directly. Instead, it defines the following Helm repositories:

1. **Bitnami Repository**
   - **Repository URL**: `https://charts.bitnami.com/bitnami`
   - **Reconciliation Interval**: 24 hours
   - **Type**: HTTP-based repository

2. **Bitnami OCI Repository**
   - **Repository URL**: `oci://registry-1.docker.io/bitnamicharts`
   - **Reconciliation Interval**: 24 hours
   - **Type**: OCI-based repository
   - **Version**: Latest (floating version)

## Resource Glossary
This component creates the following Kubernetes resources:

### HelmRepository
- **Purpose**: Defines external Helm chart repositories that Flux can use to fetch and reconcile Helm charts.
- **Details**:
  - **Name**: `bitnami`
    - Provides access to the Bitnami public Helm chart repository via HTTP.
    - Configured with a reconciliation interval of 24 hours to ensure charts are kept up-to-date.
  - **Name**: `bitnami-oci`
    - Provides access to the Bitnami Helm chart repository hosted on an OCI registry.
    - Configured with a reconciliation interval of 24 hours and supports floating versions for charts.

## Configuration Highlights
- **Reconciliation Interval**: Both repositories are configured to reconcile every 24 hours, ensuring that the latest chart versions are available for deployment.
- **Repository Types**:
  - `bitnami`: HTTP-based repository for public charts.
  - `bitnami-oci`: OCI-based repository for charts hosted on Docker Hub.

## Deployment
- **Target Namespace**: `flux-system`
- **Resource Names**:
  - `bitnami`
  - `bitnami-oci`
- **Reconciliation Behavior**: Flux will reconcile the repositories every 24 hours to fetch updates and ensure availability of the latest charts.
