---
title: "ombi"
parent: "Apps"
grand_parent: "tpi-1"
---

# Ombi

## Overview
Ombi is a self-hosted web application that allows users to request media content for their media server. It integrates with popular media server platforms like Plex, Emby, and Jellyfin. In this deployment, Ombi is configured to use a MariaDB database for persistent storage and is exposed via an Ingress resource for external access.

This deployment consists of two HelmReleases:
1. `default--ombi`: Deploys the Ombi application.
2. `default--ombi-mariadb`: Deploys a MariaDB instance as a dependency for Ombi.

## Sub-components
### Ombi (`default--ombi`)
- **Chart**: `ombi`
- **Version**: `latest` (floating: `>=0.1.1-0`)
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Target Namespace**: `default`
- **Provides**: The main Ombi application, including the web interface and API.

### MariaDB (`default--ombi-mariadb`)
- **Chart**: `mariadb`
- **Version**: `16.5.0`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Target Namespace**: `default`
- **Provides**: A MariaDB database instance for Ombi to store its data.

## Dependencies
- `default--ombi` depends on `default--ombi-mariadb` for database storage. The MariaDB instance provides the database backend for Ombi, which is configured to use MySQL as its database type.

## Helm Chart(s)
### Ombi
- **Chart Name**: `ombi`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: `latest` (floating: `>=0.1.1-0`)

### MariaDB
- **Chart Name**: `mariadb`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: `16.5.0`

## Resource Glossary
### Networking
- **Ingress**: Exposes the Ombi application externally at `ombi.${domain_wahoo_li:=wahoo.li}`. Includes authentication integration with Authentik via NGINX annotations.
- **Service**: A ClusterIP service named `ombi` exposes the application on port `3579` for internal communication.
- **HTTPRoute**: Configures routing for the Ombi application within the cluster, targeting the `ombi` service on port `3579`.

### Storage
- **ConfigMap**: 
  - `ombi-configuration-m45h7dk2t6`: Contains database connection settings for Ombi.
  - `ombi-values-g24cf72422`: Provides base and custom Helm values for the Ombi deployment.
  - `ombi-mariadb-values-4tkftt4548`: Provides Helm values for the MariaDB deployment.
- **Persistent Volume**: Configured for both Ombi and MariaDB to ensure data persistence.

### Security
- **Certificate**: A TLS certificate named `ombi-ingress` is issued by the `letsencrypt-production` ClusterIssuer for secure HTTPS access to the Ombi application.
- **ServiceAccount**: Both Ombi and MariaDB have dedicated ServiceAccounts for secure access to Kubernetes resources.
- **NetworkPolicy**: A NetworkPolicy is applied to the MariaDB StatefulSet to restrict ingress and egress traffic.

### Workloads
- **Deployment**: The Ombi application is deployed as a single replica Deployment. It includes:
  - An initContainer (`copy-configuration`) to handle configuration setup using environment variables and a ConfigMap.
  - A main container running the `lscr.io/linuxserver/ombi:4.53.4` image.
  - Liveness, readiness, and startup probes to ensure the application is running and responsive.
- **StatefulSet**: The MariaDB database is deployed as a single replica StatefulSet. It includes:
  - A container running the `ghcr.io/wahooli/docker/mariadb:11.2.3` image.
  - Persistent storage of `4Gi` for database data.
  - Custom startup and readiness probes for database health checks.

### Image Management
- **ImageRepository**: Tracks the `lscr.io/linuxserver/ombi` image for the Ombi application.
- **ImagePolicy**: Ensures the Ombi application uses the latest available image version that matches the semantic versioning range `x.x.x`.

## Configuration Highlights
- **Ombi Application**:
  - Image: `lscr.io/linuxserver/ombi:4.53.4`
  - Environment Variables:
    - `TZ`: `Europe/Helsinki`
    - `PGID`: `1000`
    - `PUID`: `1000`
  - Persistence:
    - Configuration data is stored in a ConfigMap (`ombi-configuration-m45h7dk2t6`).
    - Persistent volume for `/config` directory.
- **MariaDB**:
  - Image: `ghcr.io/wahooli/docker/mariadb:11.2.3`
  - Persistence:
    - 4Gi of storage for database data.
  - Environment Variables:
    - `TZ`: `Europe/Helsinki`
    - `MARIADB_CHARACTER_SET`: `utf8mb4`
    - `MARIADB_COLLATE`: `utf8mb4_unicode_ci`
  - Backup and restore hooks configured for Velero integration.

## Deployment
- **Target Namespace**: `default`
- **Release Names**:
  - Ombi: `ombi`
  - MariaDB: `ombi-mariadb`
- **Reconciliation Interval**: 5 minutes for both HelmReleases.
- **Install/Upgrade Behavior**:
  - Unlimited retries for failed installations.
  - Rolling updates for both Deployment and StatefulSet resources.
