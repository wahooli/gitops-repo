---
title: "tautulli"
parent: "Apps"
grand_parent: "tpi-1"
---

# tautulli

## Overview
Tautulli is a web application that monitors and provides insights into your Plex Media Server. It tracks various statistics and provides notifications for events related to your Plex server. This deployment consists of a single HelmRelease that manages the application and its associated resources.

## Sub-components
- **HelmRelease: default--tautulli**
  - **Chart:** tautulli
  - **Version:** latest (floating: >=0.1.1-0)
  - **Target Namespace:** default
  - **Provides:** Deployment, Service, PersistentVolumeClaim, and ServiceAccount for the Tautulli application.

## Helm Chart(s)
- **Chart Name:** tautulli
- **Repository:** wahooli (oci://ghcr.io/wahooli/charts) [OCI]
- **Version:** latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute:** Manages HTTP routing for Tautulli, allowing access via specified hostnames. Two routes are defined:
  - `tautulli`: Routes traffic to the backend service on port 9000.
  - `tautulli-private`: Routes traffic to the Tautulli service on port 8181.

### Storage
- **PersistentVolumeClaim:** Requests a persistent volume for storing Tautulli's configuration data, ensuring data persistence across pod restarts.

### Security
- **ServiceAccount:** Provides an identity for Tautulli to interact with the Kubernetes API, enabling it to manage resources securely.

### Workload
- **Deployment:** Manages the Tautulli application, ensuring it runs with the specified configuration. It includes:
  - **Replicas:** 1 (ensures a single instance is running).
  - **Container:** Runs the Tautulli application using the image `ghcr.io/linuxserver/tautulli:2.17.0`.
  - **Probes:** Liveness, readiness, and startup probes to monitor the health of the application.

## Configuration Highlights
- **Image Tag:** `2.17.0`
- **Environment Variables:**
  - `TZ`: Europe/Helsinki
- **Persistence:** Enabled with a 2Gi storage request for the configuration.
- **Service Annotations:** Configured for Cilium networking with global sync and affinity settings.
- **Backup Annotations:** Configured for Velero backup with daily and weekly backup settings.

## Deployment
- **Target Namespace:** default
- **Release Name:** tautulli
- **Reconciliation Interval:** 5m
- **Install Behavior:** Remediation retries are set to unlimited (-1), ensuring that the deployment will attempt to recover from failures.
