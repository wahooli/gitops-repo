---
title: "kserve-runtimes"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# kserve-runtimes

## Overview
The `kserve-runtimes` component provides a serving runtime for machine learning models, specifically utilizing the `llama-cpp` model in this deployment. It enables the deployment and management of machine learning models in a Kubernetes environment, allowing for scalable inference services.

## Sub-components
This component does not have multiple HelmReleases; it consists of a single deployment.

## Dependencies
There are no dependencies specified for this component.

## Helm Chart(s)
- **Chart Name**: kserve
- **Repository**: kserve
- **Version**: latest

## Resource Glossary
### ClusterServingRuntime
- **Purpose**: This resource defines a serving runtime for machine learning models. It specifies the container image to use, the ports for communication, and the health checks to ensure the service is running correctly.
- **Key Features**:
  - **Container**: Runs the `llama.cpp` server from the specified image.
  - **Health Checks**: Implements liveness and readiness probes to monitor the health of the service.
  - **Model Format Support**: Supports the `gguf` model format.

## Configuration Highlights
- **Container Image**: `ghcr.io/ggml-org/llama.cpp:server`
- **Ports**: Exposes port `8080` for HTTP traffic.
- **Liveness Probe**: Configured to check the `/health` endpoint every 60 seconds after an initial delay of 300 seconds.
- **Readiness Probe**: Configured to check the `/health` endpoint every 10 seconds after an initial delay of 5 seconds, with a failure threshold of 90.

## Deployment
- **Target Namespace**: `flux-system`
- **Release Name**: `llama-cpp-cpu`
- **Reconciliation Interval**: Not specified in the manifests.
- **Install/Upgrade Behavior**: Not specified in the manifests.
