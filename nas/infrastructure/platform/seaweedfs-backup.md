---
title: "seaweedfs-backup"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs-backup

## Overview
The `seaweedfs-backup` component is responsible for managing backups of SeaweedFS data within the Kubernetes cluster. It deploys a set of services that facilitate data storage and retrieval, ensuring that backups are efficiently handled and accessible.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `seaweedfs-backup--seaweedfs`
  - **Chart**: seaweedfs
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: seaweedfs-backup
  - **Provides**: StatefulSets for volume and filer management, along with necessary services and configurations for backup operations.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: seaweedfs
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routing rules for incoming HTTP requests to the SeaweedFS services. Three routes are created:
  - `seaweedfs-backup-filer`: Routes to the filer service on port 8888.
  - `seaweedfs-backup-master`: Routes to the master service on port 9333.
  - `seaweedfs-backup-s3`: Routes to the S3-compatible interface on port 8333.

### Storage
- **PersistentVolume**: Two volumes are created to store data:
  - `seaweedfs-backup-volume-data`: A 1Ti storage volume for backup data.
  - `seaweedfs-backup-filer-data`: A 1Ti storage volume for the filer data.
  
### Namespace
- **Namespace**: `seaweedfs-backup`: A dedicated namespace for isolating SeaweedFS backup resources.

### ConfigMap
- **ConfigMap**: `seaweedfs-backup-values-9682hk4gf4`: Contains configuration values for the SeaweedFS deployment, including image repository and tag, volume settings, and S3 configurations.

## Configuration Highlights
- **Image**: Uses `chrislusf/seaweedfs` with a tag of `4.37`.
- **Replica Counts**: 
  - Master: 1
  - Volume: 1
- **Persistence**: 
  - Each volume has a persistent storage request of 1Ti.
- **Post-Up Script**: Configures collections and replication settings after deployment.

## Deployment
- **Target Namespace**: `seaweedfs-backup`
- **Release Name**: `seaweedfs-backup`
- **Reconciliation Interval**: 5 minutes
- **Install Behavior**: The installation allows for unlimited retries on failure.
