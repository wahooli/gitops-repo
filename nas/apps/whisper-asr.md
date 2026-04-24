---
title: "whisper-asr"
parent: "Apps"
grand_parent: "nas"
---

# whisper-asr

## Overview
The `whisper-asr` component provides an automatic speech recognition (ASR) service using the Whisper model. It is deployed in the `default` namespace of the cluster `nas`. This service leverages GPU resources for efficient processing and is designed to handle concurrent requests for transcription.

## Sub-components
This deployment consists of a single InferenceService and a PersistentVolumeClaim, which are essential for the operation of the ASR service.

## Dependencies
There are no dependencies specified for this component.

## Helm Chart(s)
- **Chart Name:** openai-whisper-asr-webservice
- **Repository:** Not specified (assumed to be a public repository)
- **Version:** latest

## Resource Glossary
### InferenceService
- **Purpose:** This resource defines the ASR service that handles incoming requests for speech recognition. It specifies the container image, environment variables, resource limits, and scaling configurations.
- **Key Features:**
  - **Container:** Runs the `onerahmet/openai-whisper-asr-webservice:latest-gpu` image.
  - **Environment Variables:** Configures the ASR engine to use `faster_whisper` and the model to `medium`.
  - **Scaling:** Configured to scale based on concurrency with a minimum of 0 and a maximum of 1 replica.
  - **Timeout:** Set to 9000 milliseconds for request processing.

### PersistentVolumeClaim
- **Purpose:** This resource allocates persistent storage for the ASR model cache, ensuring that the model data is retained across pod restarts.
- **Specifications:**
  - **Storage Size:** Requests 10Gi of storage.
  - **Access Mode:** Set to `ReadWriteOnce`, allowing a single node to read and write to the volume.
  - **Storage Class:** Uses `topolvm-fast` for optimized storage performance.

## Configuration Highlights
- **Resource Requests/Limits:**
  - CPU: Requests 1 core, limits set to 2 cores.
  - Memory: Requests 4Gi, limits set to 6Gi.
- **Persistence:** Utilizes a PersistentVolumeClaim named `whisper-asr-models` for model caching.
- **Replica Counts:** Configured to scale between 0 and 1 replicas based on concurrency.
- **Environment Variables:**
  - `ASR_ENGINE`: Set to `faster_whisper`.
  - `ASR_MODEL`: Set to `medium`.
  - `HF_HOME`: Set to `/cache/hf`.

## Deployment
- **Target Namespace:** default
- **Release Name:** whisper-asr
- **Reconciliation Interval:** Not specified.
- **Install/Upgrade Behavior:** Not specified.
