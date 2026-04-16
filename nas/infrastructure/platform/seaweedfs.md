---
title: "seaweedfs"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs

## Overview
SeaweedFS is a distributed file system designed for high performance and scalability. In the 'nas' cluster, it serves as a storage solution, leveraging S3-compatible APIs for object storage. This deployment includes a master, volume, and filer components to manage and serve files efficiently.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `seaweedfs--seaweedfs`
  - **Chart**: `seaweedfs`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `seaweedfs`
  - **Provides**: Distributed file system capabilities with S3 compatibility.

## Dependencies
The `seaweedfs--seaweedfs` HelmRelease has a dependency:
- **cert-manager--cert-manager**: This component manages TLS certificates for secure communication within the SeaweedFS deployment.

## Helm Chart(s)
- **Chart Name**: `seaweedfs`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service**: Four services are created to expose the SeaweedFS components (master, volume, and filer) to other services and clients.
- **HTTPRoute**: Defines routing rules for HTTP traffic to the SeaweedFS filer, allowing access via specified hostnames.

### Storage
- **PersistentVolume**: A persistent volume is created to store data for SeaweedFS, ensuring data durability and availability across pod restarts.

### Security
- **ConfigMap**: Multiple ConfigMaps are created to manage configuration settings for SeaweedFS, including security settings and backup scripts.

### Workload
- **StatefulSet**: Three StatefulSets are deployed for the master, volume, and filer components, ensuring stable network identities and persistent storage.
- **Deployment**: Two deployments are created for additional components or services related to SeaweedFS.
- **CronJob**: A CronJob is set up for scheduled tasks, such as backups.

## Configuration Highlights
- **Image**: The SeaweedFS image is pulled from `chrislusf/seaweedfs` with tags `4.13` and `4.19`.
- **Persistence**: Data for the volume is stored in a PersistentVolumeClaim with a request of `1Ti`.
- **Replica Counts**: The volume has a replica count of `5`, while the master and filer have a replica count of `1`.
- **TLS**: TLS is enabled for secure communication, with certificates managed by cert-manager.
- **Backup Configuration**: A backup strategy is defined with a CronJob that runs every hour, retaining multiple backup snapshots.

## Deployment
- **Target Namespace**: `seaweedfs`
- **Release Name**: `seaweedfs`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The installation can retry indefinitely on failure, ensuring resilience during deployment.
