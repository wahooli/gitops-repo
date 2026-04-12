---
title: "seaweedfs-backup"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs-backup

## Overview
The `seaweedfs-backup` component is responsible for managing backups of SeaweedFS data within the Kubernetes cluster. It deploys a set of SeaweedFS services, including volume, filer, and master components, to facilitate data storage and retrieval. This component is crucial for ensuring data durability and availability in the `nas` cluster.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `seaweedfs-backup--seaweedfs`
  - **Chart**: seaweedfs
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: seaweedfs-backup
  - **Provides**: Services for managing SeaweedFS volumes, filers, and masters.

## Helm Chart(s)
- **Chart Name**: seaweedfs
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routes for HTTP traffic to the SeaweedFS services, allowing access to the filer and master components via specified hostnames.
  - **seaweedfs-backup-filer**: Routes traffic to the filer service on port 8888.
  - **seaweedfs-backup-master**: Routes traffic to the master service on port 9333.
  - **seaweedfs-backup-s3**: Routes traffic to the S3-compatible interface on port 8333.

### Storage
- **PersistentVolume**: Two persistent volumes are created to store data for the SeaweedFS backup:
  - **seaweedfs-backup-volume-data**: Stores volume data with a capacity of 1Ti, using a host path for storage.
  - **seaweedfs-backup-filer-data**: Stores filer data with a capacity of 1Ti, also using a host path.

### Namespace
- **Namespace**: `seaweedfs-backup` is created to isolate the SeaweedFS backup services from other components in the cluster.

### ConfigMap
- **ConfigMap**: `seaweedfs-backup-values-gc28kt5fd2` contains configuration values for the SeaweedFS deployment, including image settings, volume parameters, and post-up scripts for initializing collections.

## Configuration Highlights
- **Image**: The SeaweedFS image used is `chrislusf/seaweedfs` with tags `4.13` for base values and `4.19` for specific configurations.
- **Persistence**: Each SeaweedFS component (volume, filer) is configured with persistent storage requests of 1Ti.
- **Replica Counts**: The master and volume components are set to have a replica count of 1.
- **Post-Up Script**: The deployment includes a post-up script to create necessary collections and configure replication settings.

## Deployment
- **Target Namespace**: `seaweedfs-backup`
- **Release Name**: `seaweedfs-backup`
- **Reconciliation Interval**: 5 minutes
- **Install Behavior**: The HelmRelease is configured for automatic retries on failure, ensuring resilience during installation or upgrades.
