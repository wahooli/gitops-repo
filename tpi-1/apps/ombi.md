---
title: "ombi"
parent: "Apps"
grand_parent: "tpi-1"
---

# ombi

## Overview
Ombi is a self-hosted application that allows users to request media content and manage their media library. In this deployment, Ombi is configured to work with a MariaDB database for data persistence. This is a multi-component deployment consisting of Ombi and its database backend.

## Sub-components
### HelmRelease: default--ombi
- **Chart**: ombi
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: Ombi application deployment, including a service and deployment resources.

### HelmRelease: default--ombi-mariadb
- **Chart**: mariadb
- **Version**: 16.5.0
- **Target Namespace**: default
- **Provides**: MariaDB database deployment, including a StatefulSet, service, and necessary configuration.

## Dependencies
- **default--ombi** depends on **default--ombi-mariadb**. The MariaDB deployment provides the database backend required for Ombi to function correctly.

## Helm Chart(s)
- **Ombi**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: latest (floating: >=0.1.1-0)
  
- **MariaDB**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: 16.5.0

## Resource Glossary
### Networking
- **Service**: The Ombi service exposes the application on port 3579, allowing access to the Ombi application within the cluster.
- **HTTPRoute**: Defines routing rules for incoming HTTP traffic to the Ombi application, enabling access via specified hostnames.

### Storage
- **ConfigMap**: Several ConfigMaps are created to store configuration data for both Ombi and MariaDB, including database connection strings and application settings.

### Security
- **ServiceAccount**: Service accounts for both Ombi and MariaDB are created to manage permissions for the applications.
- **NetworkPolicy**: Ensures that only allowed traffic can reach the MariaDB database, enhancing security.

### Workload
- **Deployment**: The Ombi application is deployed as a single replica, ensuring high availability and easy management.
- **StatefulSet**: The MariaDB database is deployed as a StatefulSet to manage its persistent storage and ensure stable network identities.

## Configuration Highlights
- **Ombi**:
  - **Image**: `lscr.io/linuxserver/ombi:4.53.4`
  - **Environment Variables**: Configured with timezone (`TZ: Europe/Helsinki`) and user/group IDs (`PGID: 1000`, `PUID: 1000`).
  - **Persistence**: Enabled with a ConfigMap for configuration data.
  
- **MariaDB**:
  - **Image**: `ghcr.io/wahooli/docker/mariadb:11.2.3`
  - **Database Configuration**: Uses environment variables for database credentials and settings.
  - **Persistence**: Enabled with a size of 4Gi.

## Deployment
- **Target Namespace**: default
- **Release Name(s)**: ombi, ombi-mariadb
- **Reconciliation Interval**: 5m for both releases
- **Install/Upgrade Behavior**: Both releases are set to retry indefinitely on failure, ensuring resilience during deployment.
