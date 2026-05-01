---
title: "kserve-runtimes"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kserve-runtimes

## Overview
The `kserve-runtimes` component provides a set of serving runtimes for machine learning models, enabling the deployment and management of models in a Kubernetes cluster. This deployment includes multiple runtimes optimized for different hardware configurations, specifically CPU and CUDA-enabled environments.

## Sub-components
This component consists of the following sub-components, each represented by a `ClusterServingRuntime`:

1. **llama-cpp-cpu**
   - **Chart**: kserve
   - **Version**: latest
   - **Namespace**: flux-system
   - **Provides**: A serving runtime for the LLaMA model using CPU.

2. **llama-cpp-cuda**
   - **Chart**: kserve
   - **Version**: latest
   - **Namespace**: flux-system
   - **Provides**: A serving runtime for the LLaMA model using CUDA for GPU acceleration.

3. **vllm-cuda**
   - **Chart**: kserve
   - **Version**: latest
   - **Namespace**: flux-system
   - **Provides**: A serving runtime for the VLLM model optimized for CUDA.

## Dependencies
No dependencies are specified for this component.

## Helm Chart(s)
- **Chart Name**: kserve
- **Repository**: kserve
- **Version**: latest

## Resource Glossary
### ClusterServingRuntime
- **Purpose**: This resource defines a runtime environment for serving machine learning models.
- **Details**:
  - **llama-cpp-cpu**: Uses the image `ghcr.io/ggml-org/llama.cpp:server` and listens on port 8080. It supports the `gguf` model format.
  - **llama-cpp-cuda**: Uses the image `ghcr.io/ggml-org/llama.cpp:server-cuda` and also listens on port 8080. It supports the `gguf` model format.
  - **vllm-cuda**: Uses the image `vllm/vllm-openai:cu130-nightly` and listens on port 8000. It supports the `vllm` model format.

### ImageRepository
- **Purpose**: This resource defines the source of container images for the runtimes.
- **Details**: 
  - **llama-cpp**: Points to the image repository `ghcr.io/ggml-org/llama.cpp` and checks for updates every 24 hours.

### ImagePolicy
- **Purpose**: This resource defines policies for image updates based on tags.
- **Details**:
  - **llama-cpp-cpu**: Extracts build numbers from tags matching the pattern `^server-b(?P<build>\d+)$`.
  - **llama-cpp-cuda**: Extracts build numbers from tags matching the pattern `^server-cuda-b(?P<build>\d+)$`.

## Configuration Highlights
- **Container Probes**: Each runtime includes liveness and readiness probes to ensure the service is healthy and ready to accept traffic.
- **Environment Variables**: The `vllm-cuda` runtime includes several important environment variables for configuration, such as `VLLM_NVFP4_GEMM_BACKEND` and `PYTORCH_ALLOC_CONF`.
- **Volume Mounts**: All runtimes mount volumes for model storage, ensuring models are accessible at the specified paths.

## Deployment
- **Target Namespace**: flux-system
- **Release Names**: Not explicitly defined; managed under the `kserve` chart.
- **Reconciliation Interval**: Not specified in the manifests.
- **Install/Upgrade Behavior**: Managed by Flux, with automatic reconciliation based on the defined manifests.
