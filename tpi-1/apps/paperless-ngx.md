---
title: "paperless-ngx"
parent: "Apps"
grand_parent: "tpi-1"
---

# paperless-ngx

## Overview
`paperless-ngx` is a document management system that allows users to manage and organize their documents digitally. This deployment consists of multiple components, including a PostgreSQL database and a Redis cache, which are essential for the application's functionality.

## Sub-components
### HelmRelease: default--paperless-ngx
- **Chart**: paperless-ngx
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: The main application deployment, including a service, persistent volume claim, and deployment for managing document processing.

### HelmRelease: default--paperless-ngx-postgresql
- **Chart**: postgresql
- **Version**: 14.3.3
- **Target Namespace**: default
- **Provides**: A PostgreSQL database for storing application data, including services for database access and a stateful set for managing database instances.

### HelmRelease: default--paperless-ngx-redis
- **Chart**: redis
- **Version**: 18.19.2
- **Target Namespace**: default
- **Provides**: A Redis cache for improving application performance, including services for cache access and a stateful set for managing Redis instances.

## Dependencies
The `paperless-ngx` HelmRelease has dependencies on:
- **default--paperless-ngx-postgresql**: Provides the PostgreSQL database required for application data storage.
- **default--paperless-ngx-redis**: Provides the Redis cache for application performance optimization.

## Helm Chart(s)
### default--paperless-ngx
- **Chart**: paperless-ngx
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

### default--paperless-ngx-postgresql
- **Chart**: postgresql
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: 14.3.3

### default--paperless-ngx-redis
- **Chart**: redis
- **Repository**: bitnami (https://charts.bitnami.com/bitnami)
- **Version**: 18.19.2

## Resource Glossary
### Networking
- **Service**: Exposes the `paperless-ngx` application and its dependencies (PostgreSQL and Redis) to other services within the cluster.
- **HTTPRoute**: Routes HTTP traffic to the `paperless-ngx` service based on hostname.

### Storage
- **PersistentVolumeClaim**: Allocates storage for the `paperless-ngx` application, ensuring data persistence across pod restarts.

### Security
- **ServiceAccount**: Provides an identity for the `paperless-ngx` application to interact with the Kubernetes API.

### Workload
- **Deployment**: Manages the lifecycle of the `paperless-ngx` application, ensuring the desired number of replicas are running and handling updates.

## Configuration Highlights
- **Resource Requests/Limits**: 
  - Memory: Requests 2048Mi, Limits 6144Mi for `paperless-ngx`.
  - CPU: Requests 600m.
- **Persistence**: Enabled for the `paperless-ngx` application with a storage request of 10Gi.
- **Environment Variables**: Key variables include:
  - `PAPERLESS_DBUSER`, `PAPERLESS_DBPASS`: Database credentials sourced from a secret.
  - `PAPERLESS_PORT`: Set to "8000" for application access.
- **Init Containers**: Used to wait for PostgreSQL and Redis to be ready before starting the main application.

## Deployment
- **Target Namespace**: default
- **Release Name**: paperless-ngx
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: Remediation retries are set to unlimited, ensuring resilience during installation or upgrades.
