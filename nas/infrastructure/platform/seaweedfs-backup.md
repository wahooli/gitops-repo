---
title: "seaweedfs-backup"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs-backup

## Overview
The `seaweedfs-backup` component is responsible for managing backups of the SeaweedFS storage system within the Kubernetes cluster. It deploys the SeaweedFS chart, which includes various services such as volume management, a filer, and a master node, ensuring data durability and accessibility.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `seaweedfs-backup--seaweedfs`
  - **Chart**: `seaweedfs`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `seaweedfs-backup`
  - **Provides**: Stateful services for volume management, file storage, and master coordination.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `seaweedfs`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routing rules for incoming HTTP requests to the SeaweedFS services. There are three routes:
  - `seaweedfs-backup-filer`: Routes requests to the filer service on port 8888.
  - `seaweedfs-backup-master`: Routes requests to the master service on port 9333.
  - `seaweedfs-backup-s3`: Routes S3-compatible requests to the filer service on port 8333.

### Storage
- **PersistentVolume**: Two volumes are created for data persistence:
  - `seaweedfs-backup-volume-data`: A 1Ti storage volume for SeaweedFS data.
  - `seaweedfs-backup-filer-data`: A 1Ti storage volume for the SeaweedFS filer.

### Namespace
- **Namespace**: `seaweedfs-backup`: A dedicated namespace for isolating SeaweedFS backup resources.

### ConfigMap
- **ConfigMap**: `seaweedfs-backup-values-hkcbk6ct78`: Contains configuration values for the SeaweedFS deployment, including image settings, volume configurations, and S3 settings.

## Configuration Highlights
- **Image**: The SeaweedFS image used is `chrislusf/seaweedfs` with a tag of `4.22`.
- **Replica Counts**: 
  - Master: 1
  - Volume: 1
  - Filer: 1
- **Persistence**: Each service has persistent storage configured with a request of 1Ti.
- **Post-Up Script**: A post-up script is included to ensure the SeaweedFS master and filer are ready before creating collections.

## Deployment
- **Target Namespace**: `seaweedfs-backup`
- **Release Name**: `seaweedfs-backup`
- **Reconciliation Interval**: 5 minutes
- **Install Behavior**: The HelmRelease is set to retry indefinitely on failure.
