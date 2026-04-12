---
title: "forgejo-runner"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# forgejo-runner

## Overview
The `forgejo-runner` component is responsible for executing jobs in a Kubernetes cluster using Docker-in-Docker (DinD) technology. It allows for the execution of tasks that require a Docker environment, leveraging the Forgejo platform for continuous integration and deployment workflows. This component operates within its dedicated namespace, `forgejo-runners`, and is designed to scale based on job demand.

## Sub-components
This deployment does not have multiple HelmReleases.

## Dependencies
There are no dependencies specified for this component.

## Helm Chart(s)
- **Chart Name:** forgejo-runner
- **Repository:** code.forgejo.org
- **Version:** 12.8.2

## Resource Glossary
### Networking
- **CiliumNetworkPolicy:** This resource defines network policies that restrict egress traffic from the `forgejo-runner` pods. It allows traffic to specific services such as DNS, Forgejo, and other defined endpoints while blocking all other external traffic.

### Security
- **ServiceAccount:** The `forgejo-runner` service account is created to provide the necessary permissions for the runner to execute jobs securely within the Kubernetes environment.

### Job Execution
- **ScaledJob:** This resource manages the execution of jobs, allowing for scaling based on demand. It defines the job template, including the Docker containers to run, their commands, environment variables, and resource limits. The job is configured to run a Docker daemon and execute tasks defined in the Forgejo runner configuration.

### Configuration
- **ConfigMap:** The `forgejo-runner-registration` config map contains configuration settings for the runner, including logging levels, environment variables, and Docker settings.

### Image Management
- **ImageRepository:** This resource tracks the Docker image used by the `forgejo-runner`, specifying the image location and update interval.
- **ImagePolicy:** This resource defines the policy for updating the Docker image, ensuring that it adheres to semantic versioning rules.

## Configuration Highlights
- **Resource Requests/Limits:**
  - Runner container: 
    - Requests: CPU: 50m, Memory: 64Mi
    - Limits: CPU: 500m, Memory: 512Mi
  - Daemon container:
    - Requests: CPU: 500m, Memory: 1Gi
    - Limits: CPU: 2, Memory: 16Gi
- **Replica Counts:** Minimum of 0 and a maximum of 6 replicas for job execution.
- **Environment Variables:** Key variables include `DOCKER_HOST`, `DOCKER_TLS_VERIFY`, and `DOCKER_CONFIG`, which are essential for configuring the Docker environment within the runner.
- **Important Helm Values:** The runner configuration is defined in the `registration.yaml` file, which specifies job settings, logging levels, and Docker configurations.

## Deployment
- **Target Namespace:** `forgejo-runners`
- **Release Name:** Not specified in the manifests.
- **Reconciliation Interval:** Not explicitly defined in the manifests.
- **Install/Upgrade Behavior:** Not specified in the manifests.
