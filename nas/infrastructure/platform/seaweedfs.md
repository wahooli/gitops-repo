---
title: "seaweedfs"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs

## Overview
SeaweedFS is a distributed file system designed for high performance and scalability. In this cluster, it serves as a storage solution, providing features such as S3 compatibility and efficient data management. This deployment consists of multiple components managed by Flux, ensuring continuous delivery and operational consistency.

## Sub-components
- **HelmRelease: seaweedfs--seaweedfs**
  - **Chart**: seaweedfs
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: seaweedfs
  - **Provides**: A distributed file system with S3 compatibility, including components for volume management, filers, and master nodes.

## Dependencies
- **cert-manager--cert-manager**: This dependency is required for managing TLS certificates, ensuring secure communication within the SeaweedFS components.

## Helm Chart(s)
- **Chart**: seaweedfs
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service**: Provides stable endpoints for accessing SeaweedFS components (filer, volume, master).
- **HTTPRoute**: Manages HTTP traffic routing to the SeaweedFS filer, allowing external access based on defined hostnames.

### Storage
- **PersistentVolume**: Allocates storage for SeaweedFS data, ensuring data persistence across pod restarts. The volume is configured with a capacity of 1Ti and uses a host path for storage.

### Security
- **Backend**: Defines the backend service for the SeaweedFS filer, including TLS settings for secure communication.
- **ConfigMap**: Stores configuration data for SeaweedFS, including security settings and backup scripts.

### Workload
- **StatefulSet**: Manages the deployment of SeaweedFS components (filer, volume, master) with stable identities and persistent storage.
- **Deployment**: Used for deploying stateless components of SeaweedFS.
- **CronJob**: Schedules regular backup tasks for SeaweedFS data.

## Configuration Highlights
- **Image**: The SeaweedFS image is pulled from `chrislusf/seaweedfs` with tags `4.13` and `4.37`, ensuring the latest features and fixes.
- **Persistence**: Persistent volumes are configured for both data and S3 configurations, ensuring data durability.
- **Replica Counts**: The volume component is configured with a replica count of 5 for high availability.
- **TLS**: TLS is enabled for secure communication, with certificates managed by cert-manager.
- **Environment Variables**: Key environment variables are set for backup operations, including `SOURCE_FILER` and `TARGET_FILER`.

## Deployment
- **Target Namespace**: seaweedfs
- **Release Name**: seaweedfs
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The installation is set to retry indefinitely on failure, ensuring resilience during deployment.
