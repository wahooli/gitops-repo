---
title: "kserve"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# kserve

## Overview
Kserve is a component designed for serving machine learning models on Kubernetes. It provides a robust framework for deploying and managing inference services, enabling seamless integration with various model formats and serving runtimes. This deployment consists of multiple HelmReleases that work together to provide the full functionality of Kserve.

## Sub-components
- **kserve--kserve-crd**
  - **Chart**: kserve-crd
  - **Version**: v0.17.0
  - **Target Namespace**: kserve
  - **Provides**: CustomResourceDefinitions (CRDs) necessary for Kserve's operation, defining the schema for serving runtimes.

- **kserve--kserve**
  - **Chart**: kserve-resources
  - **Version**: v0.17.0
  - **Target Namespace**: kserve
  - **Provides**: Core resources such as services, deployments, and webhooks required for Kserve to function effectively.

## Dependencies
- **kserve--kserve** depends on **kserve--kserve-crd**.
  - **kserve--kserve-crd**: Provides the necessary CRDs for Kserve, enabling the definition of custom resources like `ClusterServingRuntime`.
  - **kserve--kserve**: Utilizes the CRDs to deploy the Kserve controller and related resources.

## Helm Chart(s)
- **kserve--kserve-crd**
  - **Chart**: kserve-crd
  - **Repository**: kserve (oci://ghcr.io/kserve/charts)
  - **Version**: v0.17.0

- **kserve--kserve**
  - **Chart**: kserve-resources
  - **Repository**: kserve (oci://ghcr.io/kserve/charts)
  - **Version**: v0.17.0

## Resource Glossary
### Networking
- **Service**: Exposes Kserve components to allow communication within the cluster and to external clients.
- **ValidatingWebhookConfiguration**: Ensures that requests to create or update Kserve resources are validated against the defined schema.

### Security
- **ClusterRole** and **ClusterRoleBinding**: Define permissions for Kserve components to interact with the Kubernetes API.
- **ServiceAccount**: Provides an identity for Kserve components to interact with the Kubernetes API securely.
- **Secret**: Stores sensitive information, such as webhook server secrets.

### Storage
- **ConfigMap**: Contains configuration data for Kserve, allowing customization of its behavior and settings.

### Custom Resources
- **CustomResourceDefinition**: Defines the schema for Kserve's custom resources, enabling users to create and manage machine learning serving runtimes.

## Configuration Highlights
- **Deployment Mode**: Set to `Knative`, allowing Kserve to leverage Knative for scaling and routing.
- **Gateway Configuration**: Configured with `domain: svc.cluster.local` and `urlScheme: http`, with Istio virtual host disabled.
- **Resource Requests/Limits**: Configurable through the `inferenceService` settings in the ConfigMap.

## Deployment
- **Target Namespace**: kserve
- **Release Names**: kserve-crd, kserve
- **Reconciliation Interval**: 10 minutes for both releases.
- **Install/Upgrade Behavior**: CRDs are created or replaced as needed, with retries on failure. The Kserve resources depend on the successful installation of the CRDs.
