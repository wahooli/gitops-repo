---
title: "sonarr"
parent: "Apps"
grand_parent: "nas"
---

# sonarr

## Overview
Sonarr is a TV series management tool that automates the downloading, sorting, and renaming of TV shows. It runs in the Kubernetes cluster 'nas' and is deployed using Flux CD for GitOps management. This deployment includes a HelmRelease that manages the Sonarr application and its associated resources.

## Sub-components
- **HelmRelease: default--sonarr**
  - **Chart:** sonarr
  - **Version:** latest (floating: >=0.1.1-0)
  - **Target Namespace:** default
  - **Provides:** Manages the deployment of the Sonarr application, including its service, persistent storage, and associated configurations.

## Dependencies
This component does not have any defined dependencies.

## Helm Chart(s)
- **Chart Name:** sonarr
- **Repository:** wahooli (oci://ghcr.io/wahooli/charts)
- **Version:** latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute:** Defines routing rules for HTTP traffic to the Sonarr application. Two routes are created:
  - `sonarr`: Routes traffic to the service on port 9000.
  - `sonarr-private`: Routes traffic to the Sonarr service on port 8989.

### Storage
- **PersistentVolumeClaim:** Requests a persistent volume for storing Sonarr's configuration data, ensuring data is retained across pod restarts. It requests 2Gi of storage.

### Security
- **ServiceAccount:** A dedicated service account for the Sonarr application, allowing it to interact with the Kubernetes API securely.

### Workload
- **Deployment:** Manages the Sonarr application pods, ensuring the desired state is maintained. It specifies:
  - **Replicas:** 1
  - **Strategy:** Recreate
  - **Container:** Runs the Sonarr application using the image `ghcr.io/linuxserver/sonarr:4.0.16`.

### Monitoring
- **ConfigMap:** Contains configuration settings for Sonarr, including environment variables and resource limits for metrics collection.

## Configuration Highlights
- **Resource Requests/Limits:** 
  - CPU limit: 200m
  - Memory limit: 60Mi
- **Persistence:** 
  - Config persistence is enabled with a PVC requesting 2Gi of storage.
- **Environment Variables:** 
  - `PGID`: 2003
  - `PUID`: 2001
  - `TZ`: Europe/Helsinki
- **Service Monitor:** Enabled for metrics scraping with a scrape interval of 300 seconds.

## Deployment
- **Target Namespace:** default
- **Release Name:** sonarr
- **Reconciliation Interval:** 5m
- **Install/Upgrade Behavior:** The deployment is configured to retry indefinitely on failure.
