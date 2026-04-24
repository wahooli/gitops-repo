---
title: "kserve"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kserve

## Overview
Kserve is a Kubernetes component designed for serving machine learning models. It provides a robust framework for deploying, managing, and scaling machine learning inference services. This deployment consists of multiple Helm releases, which work together to provide the full functionality of Kserve.

## Sub-components
### HelmRelease: kserve--kserve-crd
- **Chart**: kserve-crd
- **Version**: v0.17.0
- **Target Namespace**: kserve
- **Provides**: Custom Resource Definitions (CRDs) necessary for Kserve's operation, enabling the creation of custom resources for serving models.

### HelmRelease: kserve--kserve
- **Chart**: kserve-resources
- **Version**: v0.17.0
- **Target Namespace**: kserve
- **Provides**: Core resources for Kserve, including services, deployments, and webhook configurations that facilitate model serving and management.

## Dependencies
- **kserve--kserve** depends on **kserve--kserve-crd**. The CRDs provided by the latter are essential for the former to function correctly, as they define the custom resources that Kserve uses to manage model serving.

## Helm Chart(s)
- **kserve--kserve-crd**
  - **Repository**: kserve (oci://ghcr.io/kserve/charts)
  - **Version**: v0.17.0
  
- **kserve--kserve**
  - **Repository**: kserve (oci://ghcr.io/kserve/charts)
  - **Version**: v0.17.0

## Resource Glossary
### Networking
- **Service**: Exposes Kserve components to other services and external traffic, allowing for model inference requests.
  
### Security
- **ServiceAccount**: Provides an identity for processes that run in a Pod, allowing them to interact with the Kubernetes API.
- **Secret**: Stores sensitive information, such as credentials for accessing external storage services.

### Custom Resources
- **CustomResourceDefinition (CRD)**: Defines the structure and behavior of custom resources used by Kserve, such as `ClusterServingRuntime`.

### Configuration
- **ConfigMap**: Stores non-sensitive configuration data in key-value pairs, which can be consumed by Kserve components.

### Workload
- **Deployment**: Manages the deployment of Kserve components, ensuring that the desired number of replicas are running and available.

## Configuration Highlights
- **Deployment Mode**: Set to `Knative`, which allows for serverless deployment and scaling.
- **Gateway Configuration**: Configured to use HTTP with a domain of `svc.cluster.local`, and Istio virtual hosts are disabled.
- **Resource Requests/Limits**: Not explicitly defined in the provided manifests, but can be configured through the ConfigMap.

## Deployment
- **Target Namespace**: kserve
- **Release Names**: kserve-crd, kserve
- **Reconciliation Interval**: 10 minutes for both Helm releases.
- **Install/Upgrade Behavior**: CRDs are created or replaced during installation and upgrades, with a timeout of 10 minutes for operations.
