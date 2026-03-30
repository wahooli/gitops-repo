---
title: "ombi"
parent: "Apps"
grand_parent: "tpi-1"
---

# ombi

## Overview
Ombi is a self-hosted web application that allows users to request media content. It integrates with various media servers and provides a user-friendly interface for managing requests. This deployment consists of two Helm releases: `ombi` and `ombi-mariadb`, which work together to provide the full functionality of the application.

## Sub-components
### HelmRelease: default--ombi
- **Chart**: ombi
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: The main application deployment, including a service and a deployment for the Ombi application.

### HelmRelease: default--ombi-mariadb
- **Chart**: mariadb
- **Version**: 16.5.0
- **Target Namespace**: default
- **Provides**: A MariaDB database instance that Ombi uses for data storage, including a StatefulSet and associated services.

## Dependencies
- `default--ombi` depends on `default--ombi-mariadb`, which provides the database required for Ombi to function.

## Helm Chart(s)
- **Ombi**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: latest (floating: >=0.1.1-0)
  
- **MariaDB**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: 16.5.0

## Resource Glossary
### Networking
- **Service**: Exposes the Ombi application on a ClusterIP, allowing internal access to the application on port 3579.
- **HTTPRoute**: Defines routing rules for incoming traffic to the Ombi service, allowing it to be accessed via specific hostnames.

### Storage
- **StatefulSet**: Manages the deployment of the MariaDB database, ensuring persistent storage and stable network identities.
- **ConfigMap**: Stores configuration data for both Ombi and MariaDB, including database connection strings and application settings.

### Security
- **NetworkPolicy**: Controls the traffic flow to and from the MariaDB pods, ensuring that only allowed traffic can reach the database.
- **ServiceAccount**: Provides an identity for the Ombi and MariaDB applications to interact with the Kubernetes API.

## Configuration Highlights
- **Ombi**:
  - **Image**: `lscr.io/linuxserver/ombi:4.53.4`
  - **Environment Variables**: 
    - `TZ`: Europe/Helsinki
    - `PGID`: 1000
    - `PUID`: 1000
  - **Persistence**: Enabled with a ConfigMap for JSON configuration.
  
- **MariaDB**:
  - **Image**: `ghcr.io/wahooli/docker/mariadb:11.2.3`
  - **Database Name**: Ombi
  - **Persistence**: Enabled with a size of 4Gi.
  - **Backup Configuration**: Daily and weekly backups are configured.

## Deployment
- **Target Namespace**: default
- **Release Names**: ombi, ombi-mariadb
- **Reconciliation Interval**: 
  - Ombi: 5m
  - Ombi-MariaDB: 5m
- **Install/Upgrade Behavior**: Both releases are set to retry indefinitely on failure.
