---
title: "kserve-runtimes"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kserve-runtimes

## Overview
The `kserve-runtimes` component provides a set of serving runtimes for machine learning models within the Kubernetes cluster. It enables the deployment of various model formats, allowing for efficient inference and serving of models using different hardware configurations, such as CPU and GPU.

## Sub-components
This deployment consists of multiple `ClusterServingRuntime` resources, each tailored for specific model types and configurations:

1. **llama-cpp-cpu**
   - **Chart**: kserve
   - **Version**: latest
   - **Namespace**: flux-system
   - **Provides**: Serving runtime for the LLaMA model using CPU.

2. **llama-cpp-cuda**
   - **Chart**: kserve
   - **Version**: latest
   - **Namespace**: flux-system
   - **Provides**: Serving runtime for the LLaMA model using CUDA-enabled GPUs.

3. **speaches-cuda**
   - **Chart**: kserve
   - **Version**: latest
   - **Namespace**: flux-system
   - **Provides**: Serving runtime for the Speaches model using CUDA-enabled GPUs.

4. **vllm-cuda**
   - **Chart**: kserve
   - **Version**: latest
   - **Namespace**: flux-system
   - **Provides**: Serving runtime for the VLLM model using CUDA-enabled GPUs.

## Dependencies
No dependencies are specified for this component.

## Helm Chart(s)
- **Chart Name**: kserve
- **Repository**: kserve
- **Version**: latest

## Resource Glossary
### ClusterServingRuntime
- **Purpose**: Defines a runtime environment for serving machine learning models.
- **Key Features**:
  - **Containers**: Each runtime specifies a container image, command-line arguments, and health probes.
  - **Supported Model Formats**: Each runtime supports specific model formats, such as `gguf` for LLaMA and `whisper` for Speaches.

### ImageRepository
- **Purpose**: Manages the source of container images for the LLaMA model.
- **Key Features**: 
  - **Image**: Points to the container image repository `ghcr.io/ggml-org/llama.cpp`.
  - **Interval**: Set to check for updates every 24 hours.

### ImagePolicy
- **Purpose**: Defines policies for image updates based on tag patterns.
- **Key Features**:
  - **Filter Tags**: Extracts build numbers from image tags to manage versioning.
  - **Numerical Policy**: Ensures that images are updated in ascending order based on the build number.

## Configuration Highlights
- **Container Settings**:
  - Each `ClusterServingRuntime` has specific arguments for host and port configuration.
  - Liveness and readiness probes are configured to ensure the containers are healthy and ready to serve requests.
- **Environment Variables**: 
  - `LOG_LEVEL`, `WHISPER__INFERENCE_DEVICE`, and `HF_TOKEN` are notable environment variables used for configuring the runtimes.
- **Volume Mounts**: 
  - Models and cache directories are mounted for persistent storage.

## Deployment
- **Target Namespace**: flux-system
- **Release Names**: Not explicitly defined in the manifests, but the component is managed under the `infrastructure-platform` label.
- **Reconciliation Interval**: Not specified, defaults to Flux's standard.
- **Install/Upgrade Behavior**: Managed by Flux, ensuring the latest configurations are applied based on the defined manifests.
