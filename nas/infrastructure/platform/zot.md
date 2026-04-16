---
title: "zot"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# zot

## Overview
Zot is a container image registry that provides a secure and efficient way to store and manage container images. Deployed in the `nas` cluster, it serves as a private registry for storing images, with features such as caching, access control, and synchronization with public registries.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `registry--zot`
  - **Chart**: `zot`
  - **Version**: `0.1.104`
  - **Target Namespace**: `registry`
  - **Provides**: A StatefulSet for managing the Zot registry application, a Service for accessing it, and a ServiceAccount for permissions.

## Helm Chart(s)
- **Chart Name**: `zot`
- **Repository**: `project-zot` (http://zotregistry.dev/helm-charts)
- **Version**: `0.1.104`

## Resource Glossary
### Networking
- **Service**: A NodePort service named `zot` that exposes the registry on port 5000, allowing external access to the registry.

### Storage
- **StatefulSet**: Manages the deployment of the Zot application, ensuring that it maintains state across restarts. It includes a volume claim template for persistent storage, requesting 10Gi of storage with ReadWriteOnce access mode.

### Security
- **ServiceAccount**: A service account named `zot` that provides the necessary permissions for the Zot application to interact with the Kubernetes API.

### Configuration
- **ConfigMap**: Contains configuration data for the Zot registry, including settings for storage, HTTP access, and authentication.

## Configuration Highlights
- **Persistence**: The StatefulSet is configured to use a persistent volume with a size of 10Gi.
- **Service Type**: The service is of type NodePort, allowing external access to the registry.
- **Access Control**: The configuration includes settings for user permissions and authentication methods (e.g., htpasswd, OpenID).
- **Environment Variables**: The configuration uses Flux variables for sensitive information such as access keys and user credentials.

## Deployment
- **Target Namespace**: `registry`
- **Release Name**: `zot`
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure, with a timeout of 10 minutes for installation.
