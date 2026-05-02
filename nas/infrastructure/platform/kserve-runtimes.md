---
title: "kserve-runtimes"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# kserve-runtimes

## Overview
The `kserve-runtimes` component provides a set of serving runtimes for machine learning models in the Kubernetes cluster. It includes multiple runtimes optimized for different use cases, such as CPU and CUDA-based models. This deployment consists of multiple `ClusterServingRuntime` resources, each configured to serve specific model formats.

## Sub-components
This component does not have multiple HelmReleases; it consists of several `ClusterServingRuntime` resources deployed directly.

## Dependencies
There are no dependencies specified for this component.

## Helm Chart(s)
This component does not utilize Helm charts for deployment; it is configured using Kubernetes manifests directly.

## Resource Glossary
- **ClusterServingRuntime**: This resource defines a runtime environment for serving machine learning models. Each runtime has specific configurations, including:
  - **Containers**: Each runtime includes a container specification that defines the image to use, command-line arguments, health probes, and ports.
  - **Liveness and Readiness Probes**: These are HTTP checks that ensure the service is running and ready to accept traffic.
  - **Supported Model Formats**: Each runtime specifies the model formats it can serve, such as `gguf` for Llama and `whisper` for Speaches.

## Configuration Highlights
- **Container Images**:
  - `llama-cpp-cpu`: `ghcr.io/ggml-org/llama.cpp:server`
  - `llama-cpp-cuda`: `ghcr.io/ggml-org/llama.cpp:server-cuda`
  - `speaches-cuda`: `ghcr.io/wahooli/docker/speaches:latest-cuda`
  - `vllm-cuda`: `vllm/vllm-openai:cu130-nightly`
  
- **Environment Variables**: 
  - `LOG_LEVEL`, `WHISPER__INFERENCE_DEVICE`, `HF_HOME`, and others for the Speaches runtime.
  
- **Health Probes**: Each runtime has defined liveness and readiness probes to monitor the health of the services.

## Deployment
- **Target Namespace**: `flux-system`
- **Release Names**: Not applicable as this component is not deployed via Helm.
- **Reconciliation Interval**: Not specified.
- **Install/Upgrade Behavior**: Not specified, as this component is managed through direct Kubernetes manifests.
