---
title: "tautulli"
parent: "Apps"
grand_parent: "tpi-1"
---

# tautulli

## Overview
Tautulli is a web application that monitors and provides insights into your Plex Media Server. It tracks various statistics, such as what users are watching, and provides notifications and reports. In this deployment, Tautulli is configured to run in the `default` namespace, managed by FluxCD.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease:** default--tautulli
  - **Chart:** tautulli
  - **Version:** latest (floating: >=0.1.1-0)
  - **Target Namespace:** default
  - **Provides:** Deployment, Service, PersistentVolumeClaim, and ServiceAccount for Tautulli.

## Dependencies
This component does not have any defined dependencies.

## Helm Chart(s)
- **Chart Name:** tautulli
- **Repository:** wahooli (oci://ghcr.io/wahooli/charts)
- **Version:** latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute:** Defines routing rules for HTTP traffic to Tautulli. Two routes are created:
  - `tautulli`: Routes traffic to the service on port 9000 for the hostname `tautulli.wahoo.li`.
  - `tautulli-private`: Routes traffic to the service on port 8181 for the hostname `tautulli.absolutist.it`.

### Storage
- **PersistentVolumeClaim:** `config-tautulli` is created to provide persistent storage for Tautulli's configuration data, requesting 2Gi of storage with ReadWriteOnce access mode.

### Security
- **ServiceAccount:** `tautulli` is created to provide an identity for the Tautulli application to interact with the Kubernetes API.

### Workload
- **Deployment:** `tautulli` manages the application lifecycle, ensuring that the desired number of replicas (1) is running. It specifies the container image `ghcr.io/linuxserver/tautulli:2.16.1` and includes health checks (liveness, readiness, startup probes).

### Service
- **Service:** `tautulli` exposes the application on port 8181, allowing internal communication within the cluster.

## Configuration Highlights
- **Image Tag:** `2.16.1`
- **Environment Variables:**
  - `TZ`: Set to `Europe/Helsinki` for timezone configuration.
- **Persistence:** Enabled for configuration data, with a persistent volume claim requesting 2Gi of storage.
- **Service Annotations:** Includes Cilium-specific annotations for network policies.
- **Backup Annotations:** Configured to exclude certain volumes from backup.

## Deployment
- **Target Namespace:** default
- **Release Name:** tautulli
- **Reconciliation Interval:** 5m
- **Install/Upgrade Behavior:** Remediation retries are set to unlimited (-1).
