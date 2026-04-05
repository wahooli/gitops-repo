---
title: "paperless-ngx"
parent: "Apps"
grand_parent: "tpi-1"
---

# paperless-ngx

## Overview
`paperless-ngx` is a document management system that allows users to manage their documents digitally. It is deployed in the `tpi-1` cluster and consists of multiple components, including a PostgreSQL database and a Redis cache, to provide a complete solution for document storage and retrieval.

## Sub-components
### HelmRelease: default--paperless-ngx
- **Chart**: paperless-ngx
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: The main application deployment, including a service, persistent storage, and necessary configurations.

### HelmRelease: default--paperless-ngx-postgresql
- **Chart**: postgresql
- **Version**: 14.3.3
- **Target Namespace**: default
- **Provides**: A PostgreSQL database for storing application data, including a StatefulSet and services for database access.

### HelmRelease: default--paperless-ngx-redis
- **Chart**: redis
- **Version**: 18.19.2
- **Target Namespace**: default
- **Provides**: A Redis cache for managing session data and other temporary storage needs, including a StatefulSet and services.

## Dependencies
The `default--paperless-ngx` HelmRelease depends on:
- **default--paperless-ngx-postgresql**: Provides the PostgreSQL database for persistent data storage.
- **default--paperless-ngx-redis**: Provides Redis for caching and session management.

## Helm Chart(s)
- **paperless-ngx**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: latest (floating: >=0.1.1-0)
  
- **postgresql**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: 14.3.3
  
- **redis**
  - **Repository**: bitnami (https://charts.bitnami.com/bitnami)
  - **Version**: 18.19.2

## Resource Glossary
### Networking
- **Service**: Exposes the `paperless-ngx` application on port 8000, allowing access to the application from within the cluster.
- **HTTPRoute**: Routes HTTP traffic to the `paperless-ngx` service based on the specified hostname.

### Storage
- **PersistentVolumeClaim**: Requests 10Gi of storage for the `paperless-ngx` application to persist data across pod restarts.

### Security
- **ServiceAccount**: Provides an identity for the `paperless-ngx` application to interact with the Kubernetes API.

### Workload
- **Deployment**: Manages the deployment of the `paperless-ngx` application, ensuring that the desired number of replicas are running and handling updates.

## Configuration Highlights
- **Resource Requests/Limits**: 
  - Memory: Requests 2048Mi, Limits 6144Mi
  - CPU: Requests 600m
- **Persistence**: Enabled for application data with a 10Gi PVC.
- **Environment Variables**: Key configurations include database credentials, admin user settings, and Redis connection strings.
- **Init Containers**: Two init containers (`wait-for-redis` and `wait-for-psql`) ensure that Redis and PostgreSQL are ready before the main application starts.

## Deployment
- **Target Namespace**: default
- **Release Name**: paperless-ngx
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: Remediation retries are set to unlimited, ensuring that the application will continue to attempt installation or upgrades until successful.
