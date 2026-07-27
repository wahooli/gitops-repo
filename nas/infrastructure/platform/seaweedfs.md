---
title: "seaweedfs"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs

## Overview
SeaweedFS is a distributed file system designed for high performance and scalability. In this cluster, it serves as a storage solution, providing efficient file storage and retrieval capabilities. This deployment includes multiple components managed under a single HelmRelease.

## Sub-components
- **HelmRelease: seaweedfs--seaweedfs**
  - **Chart**: seaweedfs
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: seaweedfs
  - **Provides**: StatefulSets for volume management, services for accessing the filer and volume components, and a backup mechanism.

## Dependencies
- **cert-manager--cert-manager**: This dependency is required for managing TLS certificates used by SeaweedFS, ensuring secure communication between components.

## Helm Chart(s)
- **Chart Name**: seaweedfs
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
- **ImageRepository**: Manages the image source for SeaweedFS and Restic, ensuring the latest images are pulled from the specified repositories.
- **ImagePolicy**: Defines the versioning policy for the images, ensuring that only compatible versions are used.
- **PersistentVolume**: Allocates storage for SeaweedFS data, configured to retain data even when the pods are deleted.
- **Namespace**: Creates a dedicated namespace (`seaweedfs`) for organizing all related resources.
- **HTTPRoute**: Configures routing for HTTP traffic to the SeaweedFS filer, enabling access via specified hostnames.
- **Backend**: Defines the backend service for the SeaweedFS filer, specifying TLS settings for secure communication.

## Configuration Highlights
- **Resource Requests/Limits**: Configured for CPU and memory to ensure optimal performance.
- **Persistence**: Persistent volumes are set up for both data and S3 configurations, with specified storage sizes (1Ti for volume data, 6Gi for filer data).
- **Replica Counts**: The volume component is set to have 5 replicas for high availability.
- **Environment Variables**: Key environment variables are defined for backup operations, including source and target filers.

## Deployment
- **Target Namespace**: seaweedfs
- **Release Name**: seaweedfs
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The deployment is set to retry indefinitely on failures, ensuring resilience during installation and upgrades.
