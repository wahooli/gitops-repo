---
title: "tautulli"
parent: "Apps"
grand_parent: "tpi-1"
---

# tautulli

## Overview
Tautulli is a web application that monitors and provides statistics for Plex Media Server. It allows users to track their media consumption, manage their libraries, and receive notifications about their Plex server activities. In this deployment, Tautulli is managed using Flux and Helm, ensuring automated updates and configuration management.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--tautulli`
  - **Chart**: tautulli
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: A web application for monitoring Plex Media Server.

## Dependencies
There are no dependencies specified in this deployment.

## Helm Chart(s)
- **Chart Name**: tautulli
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: 
  - `tautulli`: Routes traffic to the Tautulli service on port 9000 for the hostname `tautulli.wahoo.li`.
  - `tautulli-private`: Routes traffic to the Tautulli service on port 8181 for the hostname `tautulli.absolutist.it`.

### Storage
- **PersistentVolumeClaim**: 
  - `config-tautulli`: Requests 2Gi of storage for Tautulli's configuration data, ensuring persistence across pod restarts.

### Security
- **ServiceAccount**: 
  - `tautulli`: Provides an identity for Tautulli pods to interact with the Kubernetes API.

### Workload
- **Deployment**: 
  - `tautulli`: Manages the Tautulli application, ensuring it runs with a single replica. It includes liveness, readiness, and startup probes for health checks.

### Other
- **ImageRepository**: 
  - `tautulli`: Tracks the Tautulli Docker image from `ghcr.io/linuxserver/tautulli`.
- **ImagePolicy**: 
  - `tautulli`: Enforces a policy to use images from the 2.x.x version range.

## Configuration Highlights
- **Image Tag**: `2.16.1`
- **Environment Variables**:
  - `TZ`: Set to `Europe/Helsinki` for timezone configuration.
- **Persistence**: Enabled with a PersistentVolumeClaim for configuration storage.
- **Service Annotations**: Includes Cilium-specific annotations for network policies.

## Deployment
- **Target Namespace**: default
- **Release Name**: tautulli
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**: Remediation retries are set to unlimited, ensuring resilience during deployment.
