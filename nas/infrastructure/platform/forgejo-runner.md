---
title: "forgejo-runner"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# forgejo-runner

## Overview
The `forgejo-runner` component is responsible for executing jobs in a Kubernetes cluster, leveraging Docker for containerized execution. It integrates with Forgejo, a self-hosted Git service, to manage CI/CD workflows. The runner operates within its dedicated namespace, providing a scalable solution for running jobs with specific configurations and resource limits.

## Sub-components
This deployment does not contain multiple HelmReleases.

## Dependencies
This deployment does not have any dependencies.

## Helm Chart(s)
This deployment does not utilize Helm charts.

## Resource Glossary
### Networking
- **CiliumNetworkPolicy**: This resource defines network policies that restrict egress traffic from the `forgejo-runner` pods to specific endpoints, enhancing security by controlling which services the runner can communicate with.

### Security
- **ServiceAccount**: The `forgejo-runner` service account is created to provide the necessary permissions for the runner to interact with the Kubernetes API securely.

### Job Management
- **ScaledJob**: This resource manages the execution of jobs, allowing for scaling based on demand. It specifies the job template, including the Docker containers to run, their commands, and resource limits.

### Configuration
- **ConfigMap**: The `forgejo-runner-registration` ConfigMap contains configuration data for the runner, including logging levels, environment variables, and job capacity settings.

### Authentication
- **TriggerAuthentication**: This resource is used to manage authentication for the runner, referencing a secret that contains the necessary credentials.

### Image Management
- **ImageRepository**: This resource defines the source of the Docker images used by the runner, specifying the image repository and the update interval.
- **ImagePolicy**: This resource sets the policy for image updates, allowing the runner to pull images that meet the specified semantic versioning criteria.

## Configuration Highlights
- **Resource Requests/Limits**: 
  - Runner container: 
    - Requests: CPU: 50m, Memory: 64Mi
    - Limits: CPU: 500m, Memory: 512Mi
  - Daemon container:
    - Requests: CPU: 500m, Memory: 1Gi
    - Limits: CPU: 2, Memory: 16Gi
- **Replica Counts**: The `ScaledJob` can scale from 0 to a maximum of 6 replicas based on job demand.
- **Environment Variables**: Key environment variables include `DOCKER_HOST`, `DOCKER_TLS_VERIFY`, and `DOCKER_CONFIG`, which configure the Docker daemon and runner behavior.
- **Timeouts**: The job has a timeout of 3 hours for execution and a shutdown timeout of 3 hours.

## Deployment
- **Target Namespace**: `forgejo-runners`
- **Release Name**: Not applicable as there are no Helm releases.
- **Reconciliation Interval**: Not specified.
- **Install/Upgrade Behavior**: Not specified.
