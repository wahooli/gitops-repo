---
title: "seaweedfs"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs

## Overview
SeaweedFS is a distributed file system designed for high performance and scalability. In this cluster, it serves as a storage solution, providing efficient data management and retrieval capabilities. This deployment includes multiple components such as volume servers, a filer, and a master server, all orchestrated via a Helm chart.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `seaweedfs--seaweedfs`
  - **Chart**: `seaweedfs`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `seaweedfs`
  - **Provides**: StatefulSets for volume servers, a filer, and a master server, along with necessary services and configurations.

## Dependencies
The `seaweedfs--seaweedfs` HelmRelease has a dependency on:
- **cert-manager--cert-manager**: This component manages TLS certificates for secure communication within the SeaweedFS deployment.

## Helm Chart(s)
- **Chart Name**: `seaweedfs`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **Service**: Four services are created to expose the SeaweedFS components (master, volume, and filer) for internal and external access.
- **HTTPRoute**: Defines routing rules for HTTP traffic to the SeaweedFS filer, allowing access via specified hostnames.

### Storage
- **PersistentVolume**: A persistent volume is provisioned to store data for the SeaweedFS volume servers, ensuring data durability and availability.

### Configuration
- **ConfigMap**: Multiple ConfigMaps are created to manage configuration settings for SeaweedFS, including security settings and backup scripts.

### StatefulSets
- **StatefulSet**: Three StatefulSets are deployed for managing the SeaweedFS volume servers, ensuring stable network identities and persistent storage.

## Configuration Highlights
- **Image**: The SeaweedFS image is pulled from `chrislusf/seaweedfs`, with tags `4.13` and `4.19` used for different components.
- **Persistence**: Volume servers have persistent storage requests of `1Ti`, while the filer and other components have their own storage configurations.
- **Replica Counts**: The volume servers are configured with a replica count of 5, while the master and filer have a replica count of 1.
- **TLS**: TLS is enabled for secure communication, with certificates managed by cert-manager.
- **Backup**: A CronJob is configured for regular backups using Restic, with a retention policy for managing backup snapshots.

## Deployment
- **Target Namespace**: `seaweedfs`
- **Release Name**: `seaweedfs`
- **Reconciliation Interval**: 5 minutes
- **Install Behavior**: The HelmRelease is set to retry indefinitely on failure, ensuring resilience during installation or upgrades.
