---
title: "zot"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# zot

## Overview
Zot is a container image registry that provides storage and management for container images. It is deployed in the `registry` namespace of the `tpi-1` cluster, facilitating image storage and retrieval with support for various authentication methods and caching strategies.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `registry--zot`
  - **Chart**: `zot`
  - **Version**: `0.1.104`
  - **Target Namespace**: `registry`
  - **Provides**: A StatefulSet for managing the Zot registry, a Service for accessing the registry, and a ServiceAccount for permissions.

## Helm Chart(s)
- **Chart Name**: `zot`
- **Repository**: `project-zot` (http://zotregistry.dev/helm-charts)
- **Version**: `0.1.104`

## Resource Glossary
### Networking
- **Service**: Exposes the Zot registry on port 5000, allowing access to the registry from within the cluster. It is configured with NodePort type and includes annotations for Cilium affinity.
  
### Storage
- **StatefulSet**: Manages the deployment of the Zot registry, ensuring that it maintains state across restarts. It includes a volume claim template for persistent storage of 10Gi, ensuring that image data is retained.

### Security
- **ServiceAccount**: Provides a dedicated account for the Zot registry to interact with the Kubernetes API, ensuring that it has the necessary permissions to operate securely.

### Configuration
- **ConfigMap**: Contains configuration data for the Zot registry, including settings for storage, HTTP access, authentication, and caching.

## Configuration Highlights
- **Persistence**: Enabled with a PersistentVolumeClaim of 10Gi.
- **Service Type**: NodePort, allowing external access to the registry.
- **Important Helm Values**:
  - `image.tag`: `v2.1.15`
  - `service.annotations`: Configured for Cilium with `service.cilium.io/global: "true"` and `service.cilium.io/affinity: "local"`.
  - `externalSecrets`: References a secret for credentials.
  
## Deployment
- **Target Namespace**: `registry`
- **Release Name**: `zot`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure with a timeout of 10 minutes for installation.
