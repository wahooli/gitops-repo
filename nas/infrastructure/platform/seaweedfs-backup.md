---
title: "seaweedfs-backup"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs-backup

## Overview
The `seaweedfs-backup` component is responsible for managing backups of SeaweedFS data in the Kubernetes cluster. It utilizes a Helm chart to deploy the necessary resources, including persistent storage and HTTP routes for accessing the backup services. This component ensures that data is securely backed up and accessible, providing a reliable solution for data management.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease: seaweedfs-backup--seaweedfs**
  - **Chart**: seaweedfs
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: seaweedfs-backup
  - **Provides**: Deploys SeaweedFS backup services, including master, volume, and filer components.

## Dependencies
There are no dependencies specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: seaweedfs
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routes for accessing the SeaweedFS backup services. There are three HTTP routes:
  - `seaweedfs-backup-filer`: Routes traffic to the filer service on port 8888.
  - `seaweedfs-backup-master`: Routes traffic to the master service on port 9333.
  - `seaweedfs-backup-s3`: Routes traffic to the S3-compatible backup service on port 8333.

### Storage
- **PersistentVolume**: Two persistent volumes are created for storing data:
  - `seaweedfs-backup-volume-data`: A 1Ti storage volume for the SeaweedFS backup data.
  - `seaweedfs-backup-filer-data`: A 1Ti storage volume for the SeaweedFS filer data.

### Other
- **Namespace**: `seaweedfs-backup`: The namespace where all resources for the SeaweedFS backup are deployed.
- **HelmRelease**: Manages the deployment of the SeaweedFS backup services.
- **ConfigMap**: Contains configuration values for the SeaweedFS backup, including image settings and post-up scripts.

## Configuration Highlights
- **Image**: Uses `chrislusf/seaweedfs` with tags `4.13` for base values and `4.18` for specific configurations.
- **Persistence**: Both the volume and filer components are configured to use persistent storage with a request of 1Ti.
- **Replica Counts**: The master and volume components are set to have a replica count of 1.
- **Post-Up Script**: Configures collections and replication settings after deployment, ensuring the backup system is ready for use.

## Deployment
- **Target Namespace**: `seaweedfs-backup`
- **Release Name**: `seaweedfs-backup`
- **Reconciliation Interval**: 5 minutes
- **Install Behavior**: The installation will retry indefinitely until successful, ensuring that the backup services are reliably deployed.
