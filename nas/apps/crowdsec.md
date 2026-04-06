---
title: "crowdsec"
parent: "Apps"
grand_parent: "nas"
---

# crowdsec

The `crowdsec` component is deployed in the `nas` cluster using Flux and consists of two main Helm releases: `crowdsec` and `crowdsec-patroni`. This deployment utilizes the CrowdSec security automation tool to protect applications by analyzing logs and detecting threats.

## Helm Releases

### crowdsec

- **Chart**: crowdsec
- **Version**: 0.19.5
- **Repository**: [crowdsec](https://crowdsecurity.github.io/helm-charts)
- **Namespace**: `crowdsec`
- **Release Name**: `crowdsec`
- **Install Interval**: 5 minutes
- **Values**:
  - Base configuration is defined in `values-base.yaml`.
  - Shared configuration is defined in `values-shared.yaml`.
  - Additional configurations can be provided through optional ConfigMaps.

#### Key Configuration Values
- **Container Runtime**: `containerd`
- **LAPI Dashboard**: Disabled
- **Agent Environment Variables**:
  - `COLLECTIONS`: "crowdsecurity/http-cve"
  - `DB_PASSWORD`: Database password for CrowdSec.
- **Logging Configuration**: Logs are output in JSON format with a warning level.

### crowdsec-patroni

- **Chart**: patroni
- **Version**: `>=0.1.0-0`
- **Namespace**: `crowdsec`
- **Release Name**: `crowdsec-patroni`
- **Install Interval**: 5 minutes
- **Values**:
  - PostgreSQL configuration for the CrowdSec database.
  - Backup scripts and persistence settings are enabled.
  - Cilium network policies are defined to manage traffic between pods.

#### Key Configuration Values
- **PostgreSQL Database**: 
  - Database name: `crowdsec`
  - Username: `crowdsec`
  - Password: Configurable via environment variables.
- **Replication**: Configured for high availability with a defined number of replicas.
- **Backup**: Weekly and daily backups are enabled.

## Networking

- **HTTPRoute**: `crowdsec-api`
  - **Hostnames**: `crowdsec-api.<domain>`
  - **Backend**: Routes traffic to the `crowdsec-service` on port 8080.
  
## Image Management

- **Image Repository**: `crowdsecurity/crowdsec`
- **Image Policy**: Managed via Flux with a semver range policy.

## Namespace

The `crowdsec` component is deployed in its own namespace, ensuring isolation and management of resources specific to CrowdSec.

## Dependencies

The `crowdsec` release depends on the `crowdsec-patroni` release, which manages the PostgreSQL database required for CrowdSec's operation. 

This documentation provides a high-level overview of the `crowdsec` deployment in the Kubernetes cluster, detailing its configuration, networking, and dependencies. For further customization, refer to the respective ConfigMaps and Helm chart documentation.
