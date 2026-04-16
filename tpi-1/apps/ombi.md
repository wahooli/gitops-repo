---
title: "ombi"
parent: "Apps"
grand_parent: "tpi-1"
---

# ombi

## Overview
Ombi is a self-hosted application that allows users to request media content and manage their media library. In this deployment, Ombi is set up alongside a MariaDB database to store its data. This is a multi-component deployment consisting of Ombi and its database backend.

## Sub-components
### HelmRelease: default--ombi
- **Chart**: ombi
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: Ombi application deployment, including a Service, Deployment, and ServiceAccount.

### HelmRelease: default--ombi-mariadb
- **Chart**: mariadb
- **Version**: 16.5.0
- **Target Namespace**: default
- **Provides**: MariaDB database deployment, including a StatefulSet, Service, ServiceAccount, and NetworkPolicy.

## Dependencies
- **default--ombi** depends on **default--ombi-mariadb**. The MariaDB instance provides the necessary database backend for the Ombi application.

## Helm Chart(s)
- **Ombi**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: latest (floating: >=0.1.1-0)
  
- **MariaDB**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: 16.5.0

## Resource Glossary
### Networking
- **Service**: Exposes the Ombi application on port 3579, allowing internal and external access.
- **HTTPRoute**: Manages routing for the Ombi application, defining how requests are handled and forwarded to the service.

### Storage
- **ConfigMap**: Stores configuration data for both Ombi and MariaDB, including database connection strings and application settings.
- **StatefulSet**: Manages the MariaDB database instance, ensuring data persistence and stable network identities.

### Security
- **ServiceAccount**: Provides an identity for the Ombi and MariaDB applications to interact with the Kubernetes API.
- **NetworkPolicy**: Controls the traffic flow to and from the MariaDB instance, enhancing security by restricting access.

## Configuration Highlights
- **Ombi**:
  - **Image**: `lscr.io/linuxserver/ombi:4.53.4`
  - **Environment Variables**: 
    - `TZ`: Europe/Helsinki
    - `PGID`: 1000
    - `PUID`: 1000
  - **Persistence**: ConfigMap used for storing Ombi configuration.
  
- **MariaDB**:
  - **Image**: `ghcr.io/wahooli/docker/mariadb:11.2.3`
  - **Database Name**: Ombi
  - **Persistence**: Enabled with a size of 4Gi.
  - **Backup Configuration**: Daily and weekly backups are configured.

## Deployment
- **Target Namespace(s)**: default
- **Release Name(s)**: ombi, ombi-mariadb
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: Automatic retries on failure, with no limit on retries for the Ombi release.
