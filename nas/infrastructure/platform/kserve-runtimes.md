---
title: "kserve-runtimes"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kserve-runtimes

## Overview
The `kserve-runtimes` component provides a set of serving runtimes for machine learning models within the Kubernetes cluster. It includes multiple runtimes optimized for different hardware configurations, such as CPU and CUDA-enabled environments. This is a multi-component deployment consisting of several `ClusterServingRuntime` resources that facilitate the serving of various model formats.

## Sub-components
- **llama-cpp-cpu**
  - **Chart**: kserve
  - **Version**: latest
  - **Namespace**: flux-system
  - **Provides**: A serving runtime for CPU-based inference using the LLaMA model.

- **llama-cpp-cuda**
  - **Chart**: kserve
  - **Version**: latest
  - **Namespace**: flux-system
  - **Provides**: A serving runtime for CUDA-enabled inference using the LLaMA model.

- **speaches-cuda**
  - **Chart**: kserve
  - **Version**: latest
  - **Namespace**: flux-system
  - **Provides**: A serving runtime for CUDA-enabled inference using the Whisper model.

- **vllm-cuda**
  - **Chart**: kserve
  - **Version**: v0.20.1-cu129
  - **Namespace**: flux-system
  - **Provides**: A serving runtime for CUDA-enabled inference using the VLLM model.

## Dependencies
No dependencies are specified for this component.

## Helm Chart(s)
- **Chart Name**: kserve
  - **Repository**: https://github.com/kserve/kserve
  - **Version**: latest

- **Chart Name**: kserve
  - **Repository**: https://github.com/kserve/kserve
  - **Version**: latest

- **Chart Name**: kserve
  - **Repository**: https://github.com/kserve/kserve
  - **Version**: latest

- **Chart Name**: kserve
  - **Repository**: https://github.com/kserve/kserve
  - **Version**: v0.20.1-cu129

## Resource Glossary
### ClusterServingRuntime
- **Purpose**: Defines a runtime environment for serving machine learning models. Each runtime specifies the container image, arguments, and health checks.
- **Key Attributes**:
  - **Containers**: Each runtime includes a container definition with configuration for health checks (liveness and readiness probes), ports, and volume mounts.
  - **Supported Model Formats**: Specifies the model formats that the runtime can serve, such as `gguf` for LLaMA and `whisper` for the Whisper model.

### ImageRepository
- **Purpose**: Manages the image repository for the LLaMA model, ensuring that the latest images are pulled from the specified container registry.
- **Key Attributes**:
  - **Image**: The repository URL for the LLaMA model images.
  - **Interval**: The frequency at which the image repository is checked for updates.

### ImagePolicy
- **Purpose**: Defines policies for image updates based on tag patterns. It ensures that the correct image versions are used for deployments.
- **Key Attributes**:
  - **FilterTags**: Specifies the pattern to extract build numbers from image tags.
  - **ImageRepositoryRef**: References the associated image repository.

## Configuration Highlights
- **Container Arguments**: Each runtime specifies arguments for host and port configuration, model format handling, and parallel processing.
- **Environment Variables**: The `speaches-cuda` and `vllm-cuda` runtimes include environment variables for logging levels, inference device settings, and Hugging Face token management.
- **Health Checks**: Each runtime has defined liveness and readiness probes to ensure service availability.
- **Volume Mounts**: Runtimes mount specific paths for model storage and caching.

## Deployment
- **Target Namespace**: `flux-system`
- **Release Names**: `llama-cpp-cpu`, `llama-cpp-cuda`, `speaches-cuda`, `vllm-cuda`
- **Reconciliation Interval**: 24 hours for image updates
- **Install/Upgrade Behavior**: Managed by Flux, ensuring that the latest configurations are applied automatically based on the defined manifests.
