---
title: "zot"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# zot

## Overview
Zot is a container image registry that provides a lightweight and efficient way to store and manage container images. Deployed in the `nas` cluster, it serves as a private registry for storing images, with features such as caching, access control, and external authentication. This deployment includes a single HelmRelease that manages the Zot application.

## Dependencies
The `registry--zot` HelmRelease depends on the `seaweedfs--seaweedfs` component, which provides the underlying storage for the Zot registry. SeaweedFS is a distributed file system that Zot uses to store its images.

## Helm Chart(s)
- **Chart Name:** zot
- **Repository:** project-zot (http://zotregistry.dev/helm-charts)
- **Version:** 0.1.104

## Resource Glossary
### Networking
- **Service:** A Kubernetes Service of type NodePort that exposes the Zot registry on port 5000, allowing external access to the registry. It includes annotations for Cilium to manage network policies.

### Storage
- **StatefulSet:** Manages the deployment of the Zot application, ensuring that there is always one replica running. It uses a PersistentVolumeClaim (PVC) to request 10Gi of storage with ReadWriteOnce access mode for storing registry data.

### Security
- **ServiceAccount:** A service account named `zot` that is used by the Zot application to interact with the Kubernetes API.

### Configuration
- **ConfigMap:** Contains configuration data for Zot, including the main configuration file (`config.json`) and Helm values for the deployment.

## Configuration Highlights
- **Image:** The Zot container image is pulled from `ghcr.io/project-zot/zot:v2.1.18`.
- **Persistence:** A PersistentVolumeClaim is created to provide 10Gi of storage for the registry.
- **Service Type:** The service is configured as a NodePort, allowing external access.
- **Access Control:** The configuration includes settings for authentication and access control, utilizing external secrets for credentials.

## Deployment
- **Target Namespace:** registry
- **Release Name:** zot
- **Reconciliation Interval:** 10 minutes
- **Install/Upgrade Behavior:** The installation includes a timeout of 10 minutes and allows for unlimited retries on failure.
