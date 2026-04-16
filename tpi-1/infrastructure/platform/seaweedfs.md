---
title: "seaweedfs"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# seaweedfs

## Overview
SeaweedFS is a distributed file system designed for high performance and scalability. It provides a simple interface for storing and retrieving files, and it is particularly well-suited for cloud-native applications. In the `tpi-1` cluster, SeaweedFS is deployed to manage file storage efficiently, leveraging its distributed architecture.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `seaweedfs--seaweedfs`
  - **Chart**: `seaweedfs`
  - **Version**: latest (floating: >=0.1.0-0)
  - **Target Namespace**: `seaweedfs`
  - **Provides**: Distributed file storage capabilities through various components including master, volume, and filer services.

## Dependencies
The `seaweedfs--seaweedfs` HelmRelease has a dependency on:
- **cert-manager--cert-manager**: This component manages TLS certificates for secure communication within the SeaweedFS deployment.

## Helm Chart(s)
- **Chart Name**: `seaweedfs`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.0-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routing rules for HTTP traffic to the SeaweedFS filer service, allowing access via specified hostnames.
- **Backend**: Represents the SeaweedFS filer service endpoints, enabling traffic routing and TLS configuration.

### Storage
- **StatefulSet**: Manages the deployment of SeaweedFS components (master, volume, and filer) ensuring stable network identities and persistent storage.
- **ConfigMap**: Stores configuration data for SeaweedFS, including security settings and master configurations.

### Security
- **ImagePolicy**: Defines the policy for managing image updates for the SeaweedFS container images, ensuring that only images matching the specified semantic versioning are deployed.
- **ImageRepository**: Specifies the source of the SeaweedFS container images, allowing for automated updates based on the defined policy.

## Configuration Highlights
- **Image**: The SeaweedFS image is pulled from `chrislusf/seaweedfs`, with tags `4.13` and `4.19` specified for different components.
- **Persistence**: 
  - Volume data is stored in persistent volume claims with a request of `100Gi`.
  - Filer and S3 configurations are stored in ConfigMaps, ensuring that settings are easily manageable.
- **Replica Counts**: 
  - The master has a replica count of `1`.
  - The volume component has a replica count of `4`, ensuring high availability and redundancy.
- **TLS Configuration**: TLS is enabled for secure communication, with certificates managed by cert-manager.

## Deployment
- **Target Namespace**: `seaweedfs`
- **Release Name**: `seaweedfs`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: The installation allows for unlimited retries on failure, ensuring resilience during deployment.
