---
title: "forgejo-runner"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# forgejo-runner

## Overview
The `forgejo-runner` component is responsible for executing jobs in a Kubernetes cluster using the Forgejo CI/CD system. It leverages KEDA (Kubernetes Event-driven Autoscaling) to scale job execution based on demand, ensuring efficient resource utilization. This component operates within its own namespace, `forgejo-runners`, and includes necessary configurations for Docker-in-Docker (DinD) to facilitate containerized job execution.

## Sub-components
This deployment does not have multiple HelmReleases.

## Dependencies
This deployment does not have any dependencies.

## Helm Chart(s)
This deployment does not utilize any Helm charts.

## Resource Glossary
- **Namespace**: `forgejo-runners` - A dedicated namespace for isolating the resources related to the Forgejo runner.
- **ServiceAccount**: `forgejo-runner` - Provides an identity for processes that run in the `forgejo-runner` pods, allowing them to interact with the Kubernetes API.
- **TriggerAuthentication**: `forgejo-runner-creds` - Manages authentication credentials for the Forgejo runner, referencing a Kubernetes secret for secure access.
- **ScaledJob**: `forgejo-runner` - Defines the job execution logic, including the Docker daemon setup and job execution commands. It specifies how many replicas to run based on demand and manages job lifecycle.
- **CiliumNetworkPolicy**: `forgejo-runner-restrict` - Enforces network policies to control traffic to and from the `forgejo-runner` pods, enhancing security by restricting access to only necessary services.
- **ImageRepository**: `forgejo-runner` - Tracks the Docker image used by the runner, allowing for automated updates based on the specified policy.
- **ImagePolicy**: `forgejo-runner` - Defines the policy for image updates, ensuring that only images matching the specified semantic versioning criteria are used.
- **ConfigMap**: `forgejo-runner-registration` - Contains configuration data for the runner, including job settings, environment variables, and Docker configuration.

## Configuration Highlights
- **Resource Requests/Limits**:
  - Runner container: Requests 50m CPU and 64Mi memory; limits 500m CPU and 512Mi memory.
  - Daemon container: Requests 500m CPU and 1Gi memory; limits 2 CPU and 16Gi memory.
- **ScaledJob Configuration**:
  - Minimum replicas: 0
  - Maximum replicas: 6
  - Polling interval for job triggers: 10 seconds.
- **Environment Variables**:
  - `DOCKER_HOST`: Configured for Docker daemon communication.
  - `DOCKER_TLS_VERIFY`: Set to "1" for secure Docker connections.
- **Volume Mounts**: Includes mounts for Docker certificates, runner data, and configuration files.

## Deployment
- **Target Namespace**: `forgejo-runners`
- **Release Name**: Not applicable as this deployment does not use Helm.
- **Reconciliation Interval**: Not applicable as this deployment does not use Helm.
- **Install/Upgrade Behavior**: Not applicable as this deployment does not use Helm.
