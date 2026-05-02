---
title: "open-webui"
parent: "Apps"
grand_parent: "nas"
---

# open-webui

## Overview
The `open-webui` component provides a web-based user interface for interacting with various services, including support for OpenAI APIs and WebSocket communication. It is deployed in the `open-webui` namespace and utilizes Redis for managing WebSocket connections.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `open-webui--open-webui`
  - **Chart**: `open-webui`
  - **Version**: latest
  - **Target Namespace**: `open-webui`
  - **Provides**: A web application with features such as OAuth2 authentication, WebSocket support, and integration with OpenAI APIs.

## Dependencies
No dependencies are specified for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: `open-webui`
- **Repository**: `open-webui` (https://helm.openwebui.com/)
- **Version**: latest

## Resource Glossary
### Networking
- **Service**: 
  - `open-webui`: Exposes the main application on port 80 using ClusterIP.
  - `open-webui-redis`: Exposes the Redis service on port 6379 using ClusterIP.

### Storage
- **PersistentVolumeClaim**: 
  - `open-webui`: Requests 5Gi of storage with access mode `ReadWriteOnce`, using the `topolvm-fast` storage class for data persistence.

### Security
- **ServiceAccount**: 
  - `open-webui-sa`: A service account for the application, which does not automatically mount service account tokens.

### Workload
- **StatefulSet**: 
  - `open-webui`: Manages the deployment of the web application, ensuring it runs with a single replica and handles persistent data storage.
- **Deployment**: 
  - `open-webui-redis`: Manages the Redis instance used for WebSocket connections.

### Routing
- **HTTPRoute**: 
  - `open-webui-private`: Configures routing for the application, directing traffic to the `open-webui` service based on the specified hostname.

## Configuration Highlights
- **Resource Requests/Limits**:
  - CPU: Requests 100m, Limits 2
  - Memory: Requests 512Mi, Limits 2Gi
- **Persistence**: Enabled with a size of 5Gi and `topolvm-fast` storage class.
- **WebSocket Support**: Enabled with Redis as the manager.
- **OAuth Configuration**: Integrated with Authentik for single sign-on (SSO) capabilities.
- **Environment Variables**: Key variables include:
  - `WEBUI_NAME`: Set to `nas-chat`
  - `WEBUI_URL`: Configured for OAuth redirect
  - `ENABLE_SIGNUP`: Disabled for OAuth-only access

## Deployment
- **Target Namespace**: `open-webui`
- **Release Name**: `open-webui`
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: Automatic remediation on failures with a timeout of 10m for installations.
