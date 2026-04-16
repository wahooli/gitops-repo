---
title: "seaweedfs"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# seaweedfs

## Overview
SeaweedFS is a distributed file system designed for high performance and scalability. In this cluster, it serves as a storage solution, providing efficient file storage and retrieval capabilities. The deployment includes multiple components managed through a single HelmRelease.

## Sub-components
- **HelmRelease: seaweedfs--seaweedfs**
  - **Chart**: seaweedfs
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: seaweedfs
  - **Provides**: StatefulSets for volume management, a Filer for metadata storage, and a Master for coordinating the system.

## Dependencies
- **cert-manager--cert-manager**: This dependency is required for managing TLS certificates, ensuring secure communication within the SeaweedFS components.

## Helm Chart(s)
- **Chart Name**: seaweedfs
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
- **Namespace**: Creates a dedicated namespace `seaweedfs` for organizing resources related to this deployment.
- **StatefulSet**: Manages the deployment of SeaweedFS components, ensuring stable network identities and persistent storage.
- **Service**: Exposes the SeaweedFS components (Filer, Master, Volume) for internal communication and external access.
- **ConfigMap**: Stores configuration data for SeaweedFS, including security settings and operational parameters.
- **PersistentVolume**: Allocates storage resources for SeaweedFS volumes, ensuring data persistence across pod restarts.
- **HTTPRoute**: Defines routing rules for HTTP traffic to the SeaweedFS Filer, enabling access via specified hostnames.
- **Backend**: Configures the backend service for the SeaweedFS Filer, specifying TLS settings for secure communication.

## Configuration Highlights
- **Image**: The SeaweedFS image is pulled from `chrislusf/seaweedfs`, with tags `4.13` and `4.19` used for different components.
- **Persistence**: Persistent storage is configured for both volume data (1Ti) and S3 configuration, ensuring data durability.
- **Replica Counts**: The Filer and Volume components are set to have a replica count of 1, while the Volume service can scale up to 5 replicas.
- **TLS**: TLS is enabled for secure communication, with certificates managed by cert-manager.
- **Environment Variables**: Key environment variables are set for backup operations, including `SOURCE_FILER` and `TARGET_FILER`.

## Deployment
- **Target Namespace**: seaweedfs
- **Release Name**: seaweedfs
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The installation allows for unlimited retries on failure, ensuring resilience during deployment.
