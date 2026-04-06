---
title: "crowdsec"
parent: "Apps"
grand_parent: "tpi-1"
---

# crowdsec

## Overview
The `crowdsec` component is deployed in the `tpi-1` cluster using Flux for GitOps. It consists of a Helm release for CrowdSec and its dependencies, including a PostgreSQL database managed by Patroni.

## Helm Repository
The Helm charts for CrowdSec are sourced from the following repository:
- **Name**: crowdsec
- **URL**: [https://crowdsecurity.github.io/helm-charts](https://crowdsecurity.github.io/helm-charts)
- **Update Interval**: 24 hours

## Helm Releases
### 1. CrowdSec
- **Release Name**: crowdsec
- **Chart Version**: 0.19.5
- **Namespace**: crowdsec
- **Install Interval**: 5 minutes
- **Values**: Configurations are sourced from multiple ConfigMaps:
  - `crowdsec-values-c6cd6ckhbc` (base and shared values)
  - `crowdsec-helmrelease-overrides` (optional)

#### Key Configurations
- **Container Runtime**: containerd
- **LAPI Dashboard**: Disabled
- **Agent Environment Variables**:
  - `COLLECTIONS`: crowdsecurity/http-cve
  - `CROWDSEC_BYPASS_DB_VOLUME_CHECK`: TRUE
- **Image**: crowdsecurity/crowdsec:v1.7.7
- **Log Level**: warn
- **Database Configuration**: PostgreSQL with SSL enabled.

### 2. Patroni
- **Release Name**: crowdsec-patroni
- **Chart Version**: >=0.1.0-0
- **Namespace**: crowdsec
- **Install Interval**: 5 minutes
- **Values**: Configurations are sourced from:
  - `crowdsec-patroni-values-7g4gm6hh48`
  - `crowdsec-patroni-helmrelease-overrides` (optional)

#### Key Configurations
- **PostgreSQL User**: crowdsec
- **Database Name**: crowdsec
- **Replication**: Enabled with specified passwords.
- **PGBouncer**: Enabled with connection settings.
- **Backup Scripts**: Configured for database backups.

## Networking
### HTTPRoute
- **Name**: crowdsec-api
- **Namespace**: crowdsec
- **Hostnames**: crowdsec-api.${domain_absolutist_it:=absolutist.it}
- **Backend**: crowdsec-service on port 8080

## Image Management
- **Image Repository**: crowdsecurity/crowdsec
- **Image Policy**: Semver range for image updates.

## Namespace
- **Name**: crowdsec
- **Annotations**: 
  - `kustomize.toolkit.fluxcd.io/prune`: disabled
  - `kustomize.toolkit.fluxcd.io/ssa`: merge

## Dependencies
The `crowdsec` Helm release depends on the `crowdsec-patroni` release, which manages the PostgreSQL database.

## Conclusion
This documentation provides an overview of the `crowdsec` deployment in the `tpi-1` cluster, detailing its configuration, dependencies, and networking setup. For further customization, refer to the respective ConfigMaps and Helm values.
