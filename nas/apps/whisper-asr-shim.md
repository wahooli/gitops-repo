---
title: "whisper-asr-shim"
parent: "Apps"
grand_parent: "nas"
---

# whisper-asr-shim

## Overview
The `whisper-asr-shim` component serves as an automatic speech recognition (ASR) interface, utilizing the Speaches model for processing audio input. It is deployed in the default namespace of the cluster and is designed to handle incoming requests for speech recognition, forwarding them to the specified Speaches service.

## Sub-components
This component does not have multiple HelmReleases.

## Dependencies
This component does not have any dependencies.

## Helm Chart(s)
This component does not utilize a Helm chart for deployment; it is directly defined using Kubernetes manifests.

## Resource Glossary
### Networking
- **Service**: A ClusterIP service named `whisper-asr-shim` that exposes the deployment on port 9000, allowing internal communication within the cluster. It routes traffic to the `whisper-asr-shim` deployment.

### Workload
- **Deployment**: The `whisper-asr-shim` deployment manages a single replica of the application. It ensures that the application is running and handles the lifecycle of the pod, including scaling and updates.

## Configuration Highlights
- **Environment Variables**:
  - `ASR_ENGINE`: Set to `speaches`, indicating the ASR engine being used.
  - `SPEACHES_URL`: URL for the Speaches predictor service.
  - `SPEACHES_MODEL`: Specifies the model to be used, `Systran/faster-distil-whisper-large-v3`.
  - `SPEACHES_TIMEOUT`: Timeout for requests set to 3600 seconds.
  
- **Resource Requests/Limits**:
  - Requests: 50m CPU and 256Mi memory.
  - Limits: 2 CPU and 4Gi memory.

- **Probes**:
  - Liveness probe checks the health of the application every 30 seconds after an initial delay of 30 seconds.
  - Readiness probe checks if the application is ready to serve traffic every 10 seconds after an initial delay of 5 seconds.

## Deployment
- **Target Namespace**: default
- **Release Name**: Not applicable as this is not deployed via Helm.
- **Reconciliation Interval**: Not applicable.
- **Install/Upgrade Behavior**: Not applicable.
