---
title: "seaweedfs-backup"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs-backup

## Overview
The `seaweedfs-backup` component provides a backup solution for SeaweedFS, a distributed file system. It is deployed in the `nas` cluster and is responsible for managing persistent storage and backup operations. This component ensures data durability and accessibility through its various services and configurations.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease: seaweedfs-backup--seaweedfs**
  - **Chart**: seaweedfs
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: seaweedfs-backup
  - **Provides**: Backup services for SeaweedFS, including volume management and S3-compatible storage.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: seaweedfs
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routing rules for HTTP traffic to the SeaweedFS backup services. There are three HTTPRoutes:
  - `seaweedfs-backup-filer`: Routes traffic to the filer service on port 8888.
  - `seaweedfs-backup-master`: Routes traffic to the master service on port 9333.
  - `seaweedfs-backup-s3`: Routes traffic to the S3-compatible service on port 8333.

### Storage
- **PersistentVolume**: Two persistent volumes are created:
  - `seaweedfs-backup-volume-data`: Provides storage for SeaweedFS backup data with a capacity of 1Ti and a reclaim policy of Retain.
  - `seaweedfs-backup-filer-data`: Provides storage for the SeaweedFS filer with a capacity of 1Ti and a reclaim policy of Retain.

### Other Resources
- **Namespace**: `seaweedfs-backup`: The namespace where all resources related to the SeaweedFS backup are deployed.
- **HelmRelease**: Manages the deployment of the SeaweedFS backup services.
- **ConfigMap**: Contains configuration data for the SeaweedFS backup, including shared configurations and post-up scripts.

## Configuration Highlights
- **Image**: The SeaweedFS image used is `chrislusf/seaweedfs` with a tag of `4.40`.
- **Persistence**: Both the volume and filer services are configured with persistent storage requests of 1Ti.
- **Replica Counts**: The master and volume services are set to have a replica count of 1.
- **Post-Up Configuration**: The post-up script is enabled and includes commands to create S3 buckets and configure replication settings.

## Deployment
- **Target Namespace**: seaweedfs-backup
- **Release Name**: seaweedfs-backup
- **Reconciliation Interval**: 5m
- **Install Behavior**: The HelmRelease is set to retry indefinitely on failure.
