---
title: "kserve-runtimes"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kserve-runtimes

## Overview
The `kserve-runtimes` component provides a set of serving runtimes for machine learning models in the Kubernetes cluster. It enables the deployment of various models with specific configurations for CPU and GPU environments, facilitating inference and model serving capabilities.

## Sub-components
This deployment consists of multiple `ClusterServingRuntime` resources, each configured for different models:
- **llama-cpp-cpu**: Serves models using the CPU with the image `ghcr.io/ggml-org/llama.cpp:server-b10133`.
- **llama-cpp-cuda**: Serves models using CUDA with the image `ghcr.io/ggml-org/llama.cpp:server-cuda-b10133`.
- **speaches-cuda**: Serves speech models using CUDA with the image `ghcr.io/wahooli/docker/speaches:latest-cuda`.
- **vllm-cuda**: Serves models using CUDA with the image `vllm/vllm-openai:v0.20.1-cu129`.

## Dependencies
No dependencies are specified for this component.

## Helm Chart(s)
- **Chart Name**: kserve
  - **Repository**: Not specified
  - **Version**: latest

## Resource Glossary
### ClusterServingRuntime
- **Purpose**: This resource defines the runtime environment for serving machine learning models. Each instance specifies the container image, command-line arguments, health probes, and supported model formats.
- **Key Features**:
  - **Containers**: Each runtime has a container configured with specific arguments for model serving.
  - **Health Probes**: Liveness and readiness probes ensure that the service is operational and ready to handle requests.
  - **Supported Model Formats**: Specifies the model formats that each runtime can serve.

### ImageRepository
- **Purpose**: Manages the image repository for the `llama-cpp` images, allowing for automated updates based on the specified interval.
- **Key Features**:
  - **Image**: Points to the repository `ghcr.io/ggml-org/llama.cpp`.
  - **Interval**: Set to check for updates every 24 hours.

### ImagePolicy
- **Purpose**: Defines policies for image updates based on tag patterns for the `llama-cpp` images.
- **Key Features**:
  - **Filter Tags**: Extracts build numbers from image tags to manage versioning.
  - **Numerical Policy**: Ensures that the latest image is selected based on the build number.

## Configuration Highlights
- **Container Images**:
  - `llama-cpp-cpu`: `ghcr.io/ggml-org/llama.cpp:server-b10133`
  - `llama-cpp-cuda`: `ghcr.io/ggml-org/llama.cpp:server-cuda-b10133`
  - `speaches-cuda`: `ghcr.io/wahooli/docker/speaches:latest-cuda`
  - `vllm-cuda`: `vllm/vllm-openai:v0.20.1-cu129`
  
- **Health Probes**:
  - Liveness and readiness probes are configured for each runtime to ensure they are healthy and ready to serve requests.

- **Environment Variables**:
  - `LOG_LEVEL`, `WHISPER__INFERENCE_DEVICE`, and others are set for specific runtimes to control behavior and logging.

## Deployment
- **Target Namespace**: `flux-system`
- **Release Names**: Not specified in the manifests.
- **Reconciliation Interval**: Not specified.
- **Install/Upgrade Behavior**: Not specified, but Flux will manage the lifecycle of these resources based on the defined configurations.
