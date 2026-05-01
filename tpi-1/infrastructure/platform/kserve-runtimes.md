---
title: "kserve-runtimes"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# kserve-runtimes

## Overview
The `kserve-runtimes` component provides a serving runtime for machine learning models, enabling the deployment and management of inference services. In this deployment, a specific runtime for the Llama.cpp model is configured to serve requests over HTTP.

## Sub-components
This component does not have multiple HelmReleases.

## Dependencies
This component does not have any dependencies.

## Helm Chart(s)
- **Chart Name**: kserve
- **Repository**: https://kserve.github.io/website
- **Version**: latest

## Resource Glossary
### ClusterServingRuntime
- **Purpose**: This resource defines a serving runtime for machine learning models. It specifies the container image, configuration options, and health checks.
- **Key Features**:
  - **Containers**: The runtime runs a container based on the image `ghcr.io/ggml-org/llama.cpp:server`, which is responsible for serving the model.
  - **Health Checks**: It includes liveness and readiness probes to ensure the service is operational and ready to handle requests.
  - **Ports**: The container exposes port 8080 for incoming traffic.
  - **Volume Mounts**: It mounts a volume at `/models` for model storage.

## Configuration Highlights
- **Container Image**: `ghcr.io/ggml-org/llama.cpp:server`
- **Liveness Probe**: Configured to check the `/health` endpoint after an initial delay of 300 seconds.
- **Readiness Probe**: Configured to check the `/health` endpoint with a failure threshold of 90 and an initial delay of 5 seconds.
- **Container Port**: Exposes TCP port 8080 for serving requests.
- **Volume Mount**: The container mounts a volume named `models` at the path `/models`.

## Deployment
- **Target Namespace**: `flux-system`
- **Release Name**: `llama-cpp-cpu`
- **Reconciliation Interval**: Not specified in the manifests.
- **Install/Upgrade Behavior**: Not specified in the manifests.
