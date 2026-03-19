---
title: "ps3netsrv"
parent: "Apps"
grand_parent: "nas"
---

# ps3netsrv

## Overview
The `ps3netsrv` component provides a network server for PlayStation 3 games, enabling remote access to game files stored on a host machine. It is deployed in the `nas` cluster and managed using Flux GitOps. This component is configured to run with host networking for optimal performance and accessibility.

## Helm Chart(s)
- **Chart Name**: `ps3netsrv`
- **Repository**: `wahooli` (OCI: `oci://ghcr.io/wahooli/charts`)
- **Version**: `latest` (floating: `>=0.1.0-0`)

## Resource Glossary

### Networking
- **Service**:  
  A ClusterIP service named `ps3netsrv` exposes the application on port `38008` using TCP protocol. This allows the PlayStation 3 to connect to the server for accessing game files.

### Workload
- **Deployment**:  
  A single replica deployment named `ps3netsrv` runs the server application. It uses the image `ghcr.io/shawly/ps3netsrv:v1.10.0` and is configured with host networking (`hostNetwork: true`) for direct access to the host machine's network stack.  
  - **Probes**:  
    - Liveness, readiness, and startup probes are configured to monitor the application's health and ensure it is functioning correctly. All probes use TCP checks on port `38008`.
  - **Environment Variables**:  
    - `PS3NETSRV_PORT`: `38008` (configures the server port).  
    - Additional environment variables are sourced from the ConfigMap `ps3netsrv-env-h69bgh9bh9`.

### Storage
- **Volumes**:  
  A hostPath volume is mounted at `/games` to provide access to game files stored on the host machine. The path is configurable via the Flux variable `${ps3netsrv_games_host_path}`.

### Configuration
- **ConfigMaps**:  
  - `ps3netsrv-values-d8g92287gt`: Contains Helm values, including image tag (`v1.10.0`), deployment strategy (`Recreate`), and persistence settings for the `/games` directory.  
  - `ps3netsrv-env-h69bgh9bh9`: Provides environment variables such as `GROUP_ID`, `USER_ID`, and `TZ` (timezone).

### Security
- **ServiceAccount**:  
  A dedicated ServiceAccount named `ps3netsrv` is created for the deployment, ensuring proper access control.

### Image Management
- **ImageRepository**:  
  The `ps3netsrv` ImageRepository tracks the container image `ghcr.io/shawly/ps3netsrv` with an update interval of 24 hours.

## Configuration Highlights
- **Host Networking**: Enabled for direct network access, required for the application's functionality.  
- **Persistence**: Game files are stored on the host machine and mounted into the container at `/games`. The host path is configurable via `${ps3netsrv_games_host_path}`.  
- **Environment Variables**:  
  - `GROUP_ID`: `2001`  
  - `USER_ID`: `2007`  
  - `PS3NETSRV_PORT`: `38008`  
  - `TZ`: `Europe/Helsinki`  
  These settings are sourced from the `ps3netsrv-env-h69bgh9bh9` ConfigMap.

## Deployment
- **Target Namespace**: `default`  
- **Release Name**: `ps3netsrv`  
- **Reconciliation Interval**: Every 5 minutes  
- **Install/Upgrade Behavior**: Unlimited retries for remediation during installation.  

This component is designed for high availability and ease of management, leveraging Flux GitOps for automated updates and configuration synchronization.
