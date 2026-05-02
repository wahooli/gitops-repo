---
title: "hermes-agent"
parent: "Apps"
grand_parent: "nas"
---

# hermes-agent

## Overview
The `hermes-agent` component is a deployment that runs an agent for processing requests and managing interactions with various services. It is designed to facilitate communication and data processing within the Kubernetes cluster, specifically targeting the `hermes-agent` namespace.

## Sub-components
This component does not have multiple HelmReleases.

## Dependencies
There are no dependencies specified for this component.

## Helm Chart(s)
- **Chart Name:** hermes-agent
- **Repository:** docker.io/nousresearch
- **Version:** v2026.4.30

## Resource Glossary
### Networking
- **Service:** The `hermes-agent` service exposes the agent's API on port 80, routing traffic to the container's API port (8642). It uses a ClusterIP type, making it accessible only within the cluster.

### Storage
- **PersistentVolumeClaim:** The `hermes-agent-data` PVC requests 10Gi of storage with ReadWriteOnce access mode, using the `topolvm-fast` storage class. This is used to persist data for the agent.

### Configuration
- **ConfigMap:** The `hermes-agent-config-bm9289dfb2` config map contains configuration settings for the agent, including model parameters, terminal settings, and memory management options.

### Workload
- **Deployment:** The `hermes-agent` deployment manages a single replica of the agent container. It specifies resource requests and limits, environment variables, and readiness/liveness probes to ensure the container is healthy and ready to serve requests.

## Configuration Highlights
- **Resource Requests/Limits:** 
  - Requests: CPU: 200m, Memory: 512Mi
  - Limits: CPU: 2, Memory: 2Gi
- **Persistence:** The agent uses a PersistentVolumeClaim for data storage.
- **Replica Count:** Set to 1, indicating a single instance of the agent will run.
- **Environment Variables:**
  - `HERMES_HOME`: Set to `/opt/data`
  - `API_SERVER_HOST`: Set to `0.0.0.0`
  - `API_SERVER_PORT`: Set to `8642`
  - `GATEWAY_ALLOW_ALL_USERS`: Set to `true`

## Deployment
- **Target Namespace:** hermes-agent
- **Release Name:** hermes-agent
- **Reconciliation Interval:** 24 hours for image updates.
- **Install/Upgrade Behavior:** The deployment strategy is set to Recreate, meaning the existing pods will be terminated before new ones are created during updates.
