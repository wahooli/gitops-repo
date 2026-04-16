---
title: "jellyfin"
parent: "Apps"
grand_parent: "nas"
---

# jellyfin

## Overview
Jellyfin is an open-source media server software that allows users to organize, manage, and stream their media collections. In this Kubernetes cluster, Jellyfin is deployed to provide media streaming capabilities, leveraging the Helm chart for easy installation and management.

## Sub-components
This deployment consists of a single HelmRelease:

- **HelmRelease**: `default--jellyfin`
  - **Chart**: jellyfin
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: Deployment of the Jellyfin media server, including necessary services and configurations.

## Dependencies
There are no dependencies specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: jellyfin
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **Service**: A ClusterIP service named `jellyfin` is created to expose the Jellyfin application. It listens on ports 8096 (HTTP), 8920 (HTTPS), 1900 (UDP for service discovery), and 7359 (UDP for client discovery).

### Workload
- **Deployment**: A Deployment named `jellyfin` manages the Jellyfin application pods. It is configured to run a single replica and uses the NVIDIA runtime class for GPU support. The deployment includes liveness, readiness, and startup probes to ensure the application is healthy and ready to serve requests.

### Configuration
- **ConfigMap**: Several ConfigMaps are created to manage configuration data:
  - `jellyfin-env-b9gk6bg9gg`: Contains environment variables for the Jellyfin application.
  - `jellyfin-config-m2hmfgm9c9`: Holds the logging configuration for Jellyfin.
  - `jellyfin-values-4cdfmkc74k`: Contains Helm values for configuring the Jellyfin deployment, including persistence settings and resource requests.

## Configuration Highlights
- **Persistence**: Jellyfin is configured to use persistent storage for data, movies, and TV shows, with a specified storage request of 60Gi for the config data.
- **Environment Variables**: Configured through a ConfigMap, allowing for flexible configuration of the Jellyfin environment.
- **Resource Requests**: The deployment does not specify explicit resource requests or limits, allowing Kubernetes to manage resources dynamically.
- **Probes**: Health checks are implemented using liveness, readiness, and startup probes to ensure the application is functioning correctly.

## Deployment
- **Target Namespace**: default
- **Release Name**: jellyfin
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The deployment is configured to allow for automatic retries on failure, with a maximum retry count of unlimited.
