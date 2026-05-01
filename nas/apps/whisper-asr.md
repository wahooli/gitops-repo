---
title: "whisper-asr"
parent: "Apps"
grand_parent: "nas"
---

# whisper-asr

## Overview
The `whisper-asr` component provides an automatic speech recognition (ASR) service using the OpenAI Whisper model. It is deployed in the `default` namespace of the cluster `nas` and is designed to handle audio transcription tasks. The service is optimized for GPU usage, leveraging NVIDIA runtime for efficient processing.

## Sub-components
This deployment does not have multiple HelmReleases.

## Dependencies
This deployment does not have any dependencies.

## Helm Chart(s)
This deployment does not utilize Helm charts as it is defined directly through Kubernetes manifests.

## Resource Glossary
### InferenceService
- **Kind**: `InferenceService`
- **Purpose**: This resource defines the ASR service that handles incoming requests for audio transcription. It specifies the container image, environment variables, resource limits, and scaling behavior.
- **Key Features**:
  - **Container**: Uses the image `onerahmet/openai-whisper-asr-webservice:v1.9.1-gpu`.
  - **Environment Variables**: Configured with `ASR_ENGINE`, `ASR_MODEL`, and `HF_HOME` for model configuration.
  - **Resource Limits**: Requests 1 CPU and 4Gi of memory, with limits set to 2 CPUs and 6Gi of memory.
  - **Scaling**: Configured to scale based on concurrency with a minimum of 0 and a maximum of 1 replica.

### PersistentVolumeClaim
- **Kind**: `PersistentVolumeClaim`
- **Purpose**: This resource requests storage for caching the ASR model files, ensuring that the model is available for the service to use.
- **Specifications**: Requests 10Gi of storage with `ReadWriteOnce` access mode and uses the `topolvm-fast` storage class.

### ImageRepository
- **Kind**: `ImageRepository`
- **Purpose**: Defines the source of the container image for the ASR service, allowing Flux to monitor and update the image as needed.
- **Specifications**: Monitors the image `onerahmet/openai-whisper-asr-webservice` with a reconciliation interval of 24 hours.

### ImagePolicy
- **Kind**: `ImagePolicy`
- **Purpose**: Specifies the versioning policy for the ASR service images, allowing for automated updates based on semantic versioning.
- **Specifications**: Two policies are defined:
  - `whisper-asr`: Monitors versions in the format `vX.Y.Z`.
  - `whisper-asr-gpu`: Monitors versions in the format `vX.Y.Z-gpu`.

## Configuration Highlights
- **Resource Requests/Limits**: 
  - Requests: 1 CPU, 4Gi memory.
  - Limits: 2 CPUs, 6Gi memory.
- **Persistence**: The model cache is stored in a PersistentVolumeClaim named `whisper-asr-models`.
- **Replicas**: Configured with a minimum of 0 and a maximum of 1 replica.
- **Environment Variables**:
  - `ASR_ENGINE`: Set to `faster_whisper`.
  - `ASR_MODEL`: Set to `medium`.
  - `HF_HOME`: Set to `/cache/hf`.

## Deployment
- **Target Namespace**: `default`
- **Release Name**: Not applicable as this is not a Helm deployment.
- **Reconciliation Interval**: 24 hours for image updates.
- **Install/Upgrade Behavior**: Managed through Flux, ensuring the latest compatible image is deployed based on the defined policies.
