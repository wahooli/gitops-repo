---
title: "ombi"
parent: "Apps"
grand_parent: "tpi-1"
---

# ombi

## Overview
Ombi is a self-hosted application that allows users to request media content from various sources. It is deployed in the `tpi-1` cluster and consists of two main components: the Ombi application itself and a MariaDB database for data storage.

## Sub-components
### HelmRelease: default--ombi
- **Chart**: ombi
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: The Ombi application, including its deployment, service, and necessary configurations.

### HelmRelease: default--ombi-mariadb
- **Chart**: mariadb
- **Version**: 16.5.0
- **Target Namespace**: default
- **Provides**: A MariaDB database instance for storing Ombi's data, including a StatefulSet, service, and network policies.

## Dependencies
- **default--ombi** depends on **default--ombi-mariadb**. The MariaDB component provides the database backend required for the Ombi application to function properly.

## Helm Chart(s)
### default--ombi
- **Chart**: ombi
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts) [OCI]
- **Version**: latest (floating: >=0.1.1-0)

### default--ombi-mariadb
- **Chart**: mariadb
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts) [OCI]
- **Version**: 16.5.0

## Resource Glossary
### Networking
- **Service**: A ClusterIP service named `ombi` that exposes the Ombi application on port 3579, allowing internal communication within the cluster.
- **HTTPRoute**: Defines routing rules for incoming traffic to the Ombi application, including response header modifications for caching control.

### Storage
- **ConfigMap**: Several ConfigMaps are created to store configuration data for both Ombi and MariaDB, including database connection strings and application settings.

### Security
- **SecurityPolicy**: Enforces external authentication for the Ombi application, ensuring secure access to the service.

### Workload
- **Deployment**: A Deployment resource for the Ombi application, managing the application lifecycle, including scaling and updates.
- **StatefulSet**: A StatefulSet for the MariaDB database, ensuring stable network identities and persistent storage.

## Configuration Highlights
- **Ombi Application**:
  - **Image**: `lscr.io/linuxserver/ombi:4.53.4`
  - **Environment Variables**: Configured with timezone (`TZ: Europe/Helsinki`), and database credentials sourced from secrets.
  - **Persistence**: ConfigMap-based persistence for application configuration.
  
- **MariaDB**:
  - **Image**: `ghcr.io/wahooli/docker/mariadb:11.2.3`
  - **Database Name**: `Ombi`
  - **Persistence**: Enabled with a size of 4Gi.
  - **Backup Configuration**: Daily and weekly backups are configured.

## Deployment
- **Target Namespace**: default
- **Release Names**: ombi, ombi-mariadb
- **Reconciliation Interval**: 5m for both HelmReleases.
- **Install/Upgrade Behavior**: Both releases are configured to retry indefinitely on failure.
