---
title: "forgejo-runner"
parent: "Infrastructure / Platform"
grand_parent: "tpi-1"
---

# forgejo-runner

## Overview
The `forgejo-runner` component is responsible for executing jobs in a Kubernetes cluster using the Forgejo CI/CD platform. It utilizes Docker-in-Docker (DinD) to run containerized tasks, allowing for flexible job execution environments. This component is deployed in the `forgejo-runners` namespace and integrates with KEDA for scaling based on job demand.

## Sub-components
This deployment consists of a single logical component without multiple HelmReleases.

## Dependencies
There are no dependencies specified for this component.

## Helm Chart(s)
- **Chart Name:** forgejo-runner
- **Repository:** code.forgejo.org
- **Version:** 12.9.0

## Resource Glossary
### Networking
- **CiliumNetworkPolicy:** This resource restricts egress traffic from the `forgejo-runner` pods to specific endpoints, enhancing security by controlling which services the runner can communicate with.

### Security
- **ServiceAccount:** The `forgejo-runner` ServiceAccount is used to provide the necessary permissions for the runner to interact with the Kubernetes API.

### Job Execution
- **ScaledJob:** This resource defines the job execution logic, including the Docker-in-Docker setup. It specifies how many replicas of the job can run concurrently and manages job execution timeouts and retries.

### Configuration
- **ConfigMap:** The `forgejo-runner-registration` ConfigMap contains configuration details for the runner, including logging levels and environment variables necessary for job execution.

### Image Management
- **ImageRepository:** This resource tracks the Docker image used by the runner, ensuring that the latest version is pulled based on the defined policy.
- **ImagePolicy:** This resource defines the policy for updating the runner image, allowing for automatic updates within the specified semantic version range.

### Authentication
- **TriggerAuthentication:** This resource manages the credentials required for the runner to authenticate with the Forgejo service.

## Configuration Highlights
- **Resource Requests/Limits:**
  - Runner container: 
    - Requests: CPU: 50m, Memory: 64Mi
    - Limits: CPU: 500m, Memory: 512Mi
  - Daemon container:
    - Requests: CPU: 500m, Memory: 1Gi
    - Limits: CPU: 2, Memory: 16Gi
- **Replica Counts:** 
  - Minimum: 0
  - Maximum: 8
- **Environment Variables:** 
  - `DOCKER_HOST`, `DOCKER_TLS_VERIFY`, `DOCKER_CERT_PATH`, and others are set for the runner's operation.
- **Timeouts:** Job execution timeout is set to 3 hours, with a shutdown timeout also set to 3 hours.

## Deployment
- **Target Namespace:** `forgejo-runners`
- **Release Name:** `forgejo-runner`
- **Reconciliation Interval:** 10 seconds
- **Install/Upgrade Behavior:** Managed by Flux, ensuring the desired state is maintained in the cluster.
