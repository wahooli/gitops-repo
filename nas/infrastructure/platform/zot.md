---
title: "zot"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# zot

## Overview
Zot is a container image registry that provides a reliable and efficient way to store and manage container images. Deployed in the `nas` cluster, it facilitates image storage with features such as caching, access control, and external authentication. This deployment utilizes a Helm chart to manage its lifecycle and configuration.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `registry--zot`
  - **Chart**: `zot`
  - **Version**: `0.1.104`
  - **Target Namespace**: `registry`
  - **Provides**: A StatefulSet for managing the Zot application, a Service for exposing it, and a ServiceAccount for permissions.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `zot`
- **Repository**: `project-zot` (http://zotregistry.dev/helm-charts)
- **Version**: `0.1.104`

## Resource Glossary
### Networking
- **Service**: Exposes the Zot application on port 5000, allowing access to the registry. It is configured with annotations for Cilium networking to manage traffic affinity and global access.
  
### Storage
- **StatefulSet**: Manages the deployment of the Zot application, ensuring that it maintains its state across restarts. It includes a volume claim template for persistent storage, requesting 10Gi of storage with ReadWriteOnce access mode.

### Security
- **ServiceAccount**: Provides the necessary permissions for the Zot application to interact with the Kubernetes API.

### Configuration
- **ConfigMap**: Stores configuration data for Zot, including the main configuration file (`config.json`) and additional Helm values. This allows for flexible configuration management.

## Configuration Highlights
- **Persistence**: Enabled with a persistent volume claim requesting 10Gi of storage.
- **Service Type**: Configured as `NodePort` to expose the service externally.
- **Access Control**: Configured with external secrets for credentials management and various authentication methods.
- **Image Tag**: Uses `ghcr.io/project-zot/zot:v2.1.15` for the application image.

## Deployment
- **Target Namespace**: `registry`
- **Release Name**: `zot`
- **Reconciliation Interval**: `10m`
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure with a timeout of 10 minutes for installation.
