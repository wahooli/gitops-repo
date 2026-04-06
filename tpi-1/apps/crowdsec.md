---
title: "crowdsec"
parent: "Apps"
grand_parent: "tpi-1"
---

# crowdsec

## Overview
The `crowdsec` component is deployed in the `tpi-1` cluster using Flux CD for GitOps management. It consists of a Helm chart that manages the CrowdSec application, which provides security automation and threat detection.

## Helm Releases
### crowdsec
- **Chart Version**: 0.19.5
- **Source**: [CrowdSec Helm Repository](https://crowdsecurity.github.io/helm-charts)
- **Namespace**: `crowdsec`
- **Release Name**: `crowdsec`
- **Install Interval**: 5 minutes
- **Upgrade Remediation**: Remediate last failure
- **Timeout**: 5 minutes

#### Values Configuration
The deployment uses multiple ConfigMaps for configuration:
- **Base Values**: Configures the container runtime and disables the LAPI dashboard.
- **Shared Values**: Sets the image repository and defines environment variables for the agent.
- **Custom Values**: Contains specific configurations for the CrowdSec agent, including log settings and database connection details.

### crowdsec--crowdsec-patroni
- **Chart Version**: `>=0.1.0-0`
- **Source**: Wahooli Helm Repository
- **Namespace**: `crowdsec`
- **Release Name**: `crowdsec-patroni`
- **Install Interval**: 5 minutes

#### Patroni Values Configuration
This release manages a PostgreSQL cluster using Patroni, with configurations for:
- **Database**: Creates a `crowdsec` database and user.
- **Replication**: Configures replication settings and allows connections from specific IP ranges.
- **Backup**: Enables backup scripts and persistence for PostgreSQL data.

## Networking
### HTTPRoute
- **Name**: `crowdsec-api`
- **Namespace**: `crowdsec`
- **Hostnames**: `crowdsec-api.absolutist.it`
- **Backend**: Routes traffic to the `crowdsec-service` on port 8080.

## Image Management
### Image Repository
- **Name**: `crowdsec`
- **Image**: `crowdsecurity/crowdsec`
- **Update Interval**: 24 hours

### Image Policy
- **Policy**: Semantic versioning to track updates.

## Namespace
- **Name**: `crowdsec`
- **Annotations**: Includes configurations for pruning and service account management.

## Dependencies
The `crowdsec` HelmRelease depends on the `crowdsec--crowdsec-patroni` release, which in turn has dependencies on other services such as `cert-manager`, `reflector`, and `etcd`.

## Conclusion
The `crowdsec` component is a comprehensive security solution deployed in the `tpi-1` cluster, leveraging Kubernetes and Flux CD for efficient management and scalability. It is designed to monitor and secure applications through automated threat detection and response mechanisms.
