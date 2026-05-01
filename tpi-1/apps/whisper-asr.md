---
title: "whisper-asr"
parent: "Apps"
grand_parent: "tpi-1"
---

# whisper-asr

## Overview
The `whisper-asr` component provides an automatic speech recognition (ASR) service using the OpenAI Whisper model. It is deployed in the `default` namespace of the `tpi-1` cluster and is designed to handle audio transcription requests efficiently.

## Sub-components
This deployment does not contain multiple HelmReleases.

## Dependencies
There are no dependencies specified for this component.

## Helm Chart(s)
This component does not utilize Helm charts as it is deployed directly using Kubernetes manifests.

## Resource Glossary
### InferenceService
- **Purpose**: The `InferenceService` resource is used to deploy the ASR model as a service that can handle inference requests. It defines the container settings, including the model to be used, resource limits, and scaling behavior.
- **Key Features**:
  - **Container**: Runs the `onerahmet/openai-whisper-asr-webservice:v1.9.1` image.
  - **Environment Variables**: Configured with `ASR_ENGINE`, `ASR_MODEL`, and `HF_HOME` to specify the ASR engine and model settings.
  - **Resource Management**: Requests 2 CPU and 4Gi memory, with limits of 4 CPU and 8Gi memory.
  - **Scaling**: Configured to scale based on concurrency with a minimum of 0 and a maximum of 1 replica.

### PersistentVolume
- **Purpose**: The `PersistentVolume` provides storage for the ASR model files, allowing the service to access the necessary data for transcription.
- **Key Features**:
  - **Capacity**: 10Gi of storage with `ReadWriteMany` access mode.
  - **CSI Driver**: Utilizes the `seaweedfs-csi-driver` for storage management.

### PersistentVolumeClaim
- **Purpose**: The `PersistentVolumeClaim` requests the storage defined by the `PersistentVolume`, ensuring that the ASR service has the necessary space to operate.
- **Key Features**:
  - **Storage Request**: Requests 10Gi of storage with the same access mode as the associated `PersistentVolume`.

### ImageRepository
- **Purpose**: The `ImageRepository` resource tracks the Docker image used for the ASR service, enabling automated updates based on the specified interval.
- **Key Features**:
  - **Image**: Monitors `onerahmet/openai-whisper-asr-webservice`.
  - **Update Interval**: Set to check for new images every 24 hours.

### ImagePolicy
- **Purpose**: The `ImagePolicy` resources define the rules for image updates based on semantic versioning.
- **Key Features**:
  - **Version Filtering**: Extracts major, minor, and patch versions for both standard and GPU images, ensuring that only compatible versions are deployed.

## Configuration Highlights
- **Resource Requests/Limits**: The ASR service requests 2 CPU and 4Gi memory, with limits set to 4 CPU and 8Gi memory.
- **Persistence**: Utilizes a `PersistentVolumeClaim` for model storage, ensuring data is retained across pod restarts.
- **Scaling**: Configured to scale based on concurrency, with a minimum of 0 and a maximum of 1 replica.
- **Environment Variables**: Key variables include `ASR_ENGINE`, `ASR_MODEL`, and `HF_HOME`, which configure the ASR service's behavior.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: Not applicable as this is not deployed via Helm.
- **Reconciliation Interval**: 24 hours for image updates.
- **Install/Upgrade Behavior**: Managed through Kubernetes manifests without Helm, ensuring direct control over the deployment lifecycle.
