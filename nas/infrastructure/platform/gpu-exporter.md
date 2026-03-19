---
title: "gpu-exporter"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# gpu-exporter

## Overview

The `gpu-exporter` component deploys the NVIDIA GPU Exporter to the `kube-system` namespace in the `nas` cluster. This exporter collects GPU metrics from NVIDIA GPUs and exposes them in Prometheus-compatible format, enabling monitoring and observability of GPU usage and performance. It is particularly useful in environments where GPUs are used for workloads such as machine learning, AI, or other computationally intensive tasks.

## Helm Chart(s)

This component is deployed using a custom configuration and does not reference a specific Helm chart.

## Resource Glossary

### Networking

- **Service (`nvidia-gpu-exporter`)**  
  A `ClusterIP` service that exposes the GPU Exporter's metrics endpoint on port `9835`. This service allows Prometheus or other monitoring tools to scrape GPU metrics from the exporter.  
  - **Port:** 9835  
  - **Target Port:** 9835  
  - **Protocol:** TCP  

### Workload

- **Deployment (`nvidia-gpu-exporter`)**  
  A single-replica deployment that runs the NVIDIA GPU Exporter container. The deployment is configured to use the `nvidia` runtime class to access GPU resources.  
  - **Image:** `utkuozdemir/nvidia_gpu_exporter:1.3.2`  
  - **Replicas:** 1  
  - **Probes:**  
    - Liveness Probe: Checks the `/` endpoint on port `9835` to ensure the container is running.  
    - Readiness Probe: Checks the `/` endpoint on port `9835` to ensure the container is ready to serve traffic.  
  - **Environment Variables:**  
    - `NVIDIA_VISIBLE_DEVICES`: `all` (exposes all GPUs to the container).  
    - `NVIDIA_DRIVER_CAPABILITIES`: `all` (enables all driver capabilities).  
    - `TZ`: `UTC` (sets the timezone to UTC).  
  - **Runtime Class:** `nvidia` (ensures the container runs with GPU support).  
  - **Volumes:**  
    - `/dev/nvidiactl`: Provides access to the NVIDIA control device.  
    - `/dev/nvidia0`: Provides access to the first NVIDIA GPU device.  
    - `/usr/bin/nvidia-smi`: Mounts the `nvidia-smi` binary for GPU monitoring.  
    - `/usr/lib/x86_64-linux-gnu/libnvidia-ml.so`: Mounts the NVIDIA Management Library (libnvidia-ml).  
    - `/usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1`: Mounts the versioned NVIDIA Management Library.  

## Configuration Highlights

- **Image Version:** The component uses the `utkuozdemir/nvidia_gpu_exporter:1.3.2` image.  
- **Probes:** Liveness and readiness probes are configured to ensure the container is healthy and ready to serve metrics.  
- **Environment Variables:**  
  - `NVIDIA_VISIBLE_DEVICES` and `NVIDIA_DRIVER_CAPABILITIES` are set to `all` to ensure full GPU access and functionality.  
  - `TZ` is set to `UTC` to standardize the timezone.  
- **Runtime Class:** The `nvidia` runtime class is used to enable GPU support for the container.  
- **Volumes:** HostPath volumes are used to provide access to GPU-related files and devices on the host.  

## Deployment

- **Namespace:** `kube-system`  
- **Release Name:** `nas-gpu-exporter`  
- **Reconciliation Interval:** Managed by Flux's `infrastructure-platform` Kustomization in the `flux-system` namespace.  
- **Install/Upgrade Behavior:** Changes to the component are automatically reconciled by Flux based on the GitOps workflow.
