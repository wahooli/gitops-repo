---
title: "zot"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# zot

## Overview
Zot is a container image registry that provides a lightweight and efficient way to store and manage container images. In the 'nas' cluster, it is deployed within the `registry` namespace and is configured to use SeaweedFS for storage. Zot supports various authentication methods and offers features like caching and garbage collection.

## Dependencies
The `registry--zot` HelmRelease depends on the `seaweedfs--seaweedfs` component, which provides the underlying storage solution for the Zot registry. SeaweedFS is a distributed file system that allows for scalable and efficient storage of container images.

## Helm Chart(s)
- **Chart Name**: zot
- **Repository**: project-zot (http://zotregistry.dev/helm-charts)
- **Version**: 0.1.104

## Resource Glossary
### Networking
- **Service**: Exposes the Zot registry on port 5000 using a NodePort service type, allowing external access to the registry.
- **HTTPRoute**: Configures routing for the Zot service, enabling access via specified hostnames.

### Storage
- **StatefulSet**: Manages the deployment of the Zot application, ensuring that it maintains a stable identity and persistent storage through a PersistentVolumeClaim (PVC) for storing images.
- **ConfigMap**: Contains configuration files for Zot, including `config.json` which defines storage settings, authentication methods, and other operational parameters.

### Security
- **ServiceAccount**: Provides an identity for the Zot application to interact with the Kubernetes API, allowing it to manage resources as needed.
- **ImageRepository**: Tracks the image source for the Zot application, ensuring that the correct image is pulled for deployment.

## Configuration Highlights
- **Persistence**: The StatefulSet is configured with a PVC that requests 10Gi of storage, ensuring that image data is retained across pod restarts.
- **Service Type**: The service is set to NodePort, allowing external access to the registry.
- **Authentication**: Zot is configured to use multiple authentication methods, including API keys and OpenID Connect.
- **Environment Variables**: Several parameters are configurable via Flux variables, such as `${seaweedfs_zot_access_key}` and `${zot_admin_user}`.

## Deployment
- **Target Namespace**: registry
- **Release Name**: zot
- **Reconciliation Interval**: 10 minutes
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure, with a timeout of 10 minutes for installation.
