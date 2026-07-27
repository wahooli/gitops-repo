---
title: "forgejo-runner"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# forgejo-runner

## Overview
The `forgejo-runner` component is designed to manage and execute jobs in a Kubernetes cluster, specifically tailored for use with Forgejo, a self-hosted Git service. It utilizes KEDA (Kubernetes Event-driven Autoscaling) to scale job executions based on demand, ensuring efficient resource utilization. This component operates within its dedicated namespace, `forgejo-runners`, and is configured to interact with Docker for containerized job execution.

## Sub-components
This deployment consists of a single logical component without multiple HelmReleases.

## Dependencies
There are no dependencies specified for this component.

## Helm Chart(s)
- **Chart Name**: forgejo-runner
- **Repository**: code.forgejo.org
- **Version**: 12.13.2

## Resource Glossary
### Networking
- **CiliumNetworkPolicy**: This resource restricts network traffic to and from the `forgejo-runner` pods, allowing only specified traffic to ensure security and compliance with network policies.

### Security
- **ServiceAccount**: The `forgejo-runner` service account is created to provide an identity for the pods, allowing them to interact with the Kubernetes API securely.

### Job Management
- **ScaledJob**: This resource defines the job execution logic, including the Docker daemon setup and the execution of the `forgejo-runner` command. It specifies how many replicas of the job can run concurrently and manages job lifecycle events.

### Configuration
- **ConfigMap**: The `forgejo-runner-registration` config map holds configuration data for the runner, including logging levels, environment variables, and job capacity settings.

### Image Management
- **ImageRepository**: This resource tracks the Docker image used by the `forgejo-runner`, ensuring that the latest compatible version is pulled from the specified repository.

### Image Policy
- **ImagePolicy**: This resource defines the policy for image updates, specifying that any version greater than or equal to 12.0.0 is acceptable for deployment.

## Configuration Highlights
- **Resource Requests/Limits**: 
  - Runner container: 
    - Requests: CPU: 50m, Memory: 64Mi
    - Limits: CPU: 500m, Memory: 512Mi
  - Daemon container:
    - Requests: CPU: 500m, Memory: 1Gi
    - Limits: CPU: 2, Memory: 16Gi
- **Replica Counts**: The `ScaledJob` can scale from 0 to a maximum of 6 replicas based on demand.
- **Environment Variables**: Key environment variables include `DOCKER_HOST`, `DOCKER_TLS_VERIFY`, and `DOCKER_CONFIG`, which are essential for Docker operations within the job.

## Deployment
- **Target Namespace**: `forgejo-runners`
- **Release Name**: Not specified (single component deployment)
- **Reconciliation Interval**: Not explicitly defined in the manifests.
- **Install/Upgrade Behavior**: Managed by Flux, ensuring that the latest configurations are applied automatically based on the defined manifests.
