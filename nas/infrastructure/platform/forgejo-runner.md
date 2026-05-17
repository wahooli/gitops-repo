---
title: "forgejo-runner"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# forgejo-runner

## Overview
The `forgejo-runner` component is designed to facilitate the execution of jobs within the Forgejo ecosystem, leveraging Docker for containerized environments. It operates by managing the lifecycle of jobs through a ScaledJob resource, which allows for dynamic scaling based on workload demands. This component is deployed in the `forgejo-runners` namespace and interacts with various services within the cluster.

## Sub-components
This deployment consists of a single logical component without multiple HelmReleases.

## Dependencies
There are no explicit dependencies defined for this component.

## Helm Chart(s)
- **Chart Name**: forgejo-runner
- **Repository**: code.forgejo.org
- **Version**: 12.9.0

## Resource Glossary
### Networking
- **CiliumNetworkPolicy**: This resource restricts the network traffic for the `forgejo-runner` pods, allowing egress to specific services such as kube-dns, Forgejo, and other defined endpoints while blocking all other traffic.

### Security
- **ServiceAccount**: The `forgejo-runner` service account is used to provide permissions for the pods to interact with the Kubernetes API securely.

### Job Management
- **ScaledJob**: This resource defines the job execution logic, including the command to run the Forgejo runner, resource limits, and scaling behavior. It specifies a maximum of 6 replicas and a minimum of 0, allowing for efficient resource utilization based on demand.

### Configuration
- **ConfigMap**: The `forgejo-runner-registration` config map contains configuration details for the runner, including logging levels, environment variables, and job capacity settings.

### Image Management
- **ImageRepository**: This resource tracks the Docker image used by the runner, ensuring that it pulls the correct version of the image from the specified repository.
- **ImagePolicy**: This resource defines the policy for image updates, specifying that any version greater than or equal to 12.0.0 is acceptable.

### Authentication
- **TriggerAuthentication**: This resource manages the credentials required for the runner to authenticate with the Forgejo service.

## Configuration Highlights
- **Resource Requests/Limits**:
  - Runner container: 
    - Requests: CPU 50m, Memory 64Mi
    - Limits: CPU 500m, Memory 512Mi
  - Daemon container:
    - Requests: CPU 500m, Memory 1Gi
    - Limits: CPU 2, Memory 16Gi
- **Replica Counts**: Minimum of 0 and maximum of 6 for the ScaledJob.
- **Environment Variables**: Key environment variables include `DOCKER_HOST`, `DOCKER_TLS_VERIFY`, and `DOCKER_CONFIG`, which are essential for Docker operations within the runner.
- **Volume Mounts**: Various volumes are mounted for configuration, Docker certificates, and job data.

## Deployment
- **Target Namespace**: `forgejo-runners`
- **Release Name**: Not specified (single component deployment).
- **Reconciliation Interval**: Not explicitly defined in the manifests.
- **Install/Upgrade Behavior**: Managed by Flux, ensuring that the latest configurations are applied as defined in the GitOps repository.
