---
title: "crowdsec"
parent: "Apps"
grand_parent: "nas"
---

# crowdsec

The `crowdsec` component is deployed in the `nas` cluster using Flux and consists of two main Helm releases: `crowdsec` and `crowdsec-patroni`.

## Overview

### Helm Repository
- **Name**: crowdsec
- **URL**: [https://crowdsecurity.github.io/helm-charts](https://crowdsecurity.github.io/helm-charts)
- **Update Interval**: 24 hours

### Namespaces
- **Namespace**: crowdsec

## Helm Releases

### crowdsec
- **Release Name**: crowdsec
- **Chart**: crowdsec
- **Version**: 0.19.5
- **Interval**: 5 minutes
- **Target Namespace**: crowdsec
- **Dependencies**: 
  - `crowdsec--crowdsec-patroni`
- **Values**:
  - Configurations are sourced from multiple ConfigMaps:
    - `crowdsec-values-6fk8dh69k5` (base and shared values)
    - `crowdsec-helmrelease-overrides` (optional)

### crowdsec-patroni
- **Release Name**: crowdsec-patroni
- **Chart**: patroni
- **Version**: latest (>=0.1.0-0)
- **Interval**: 5 minutes
- **Target Namespace**: crowdsec
- **Dependencies**: 
  - `cert-manager--cert-manager`
  - `reflector--reflector`
  - `etcd--etcd`
- **Values**:
  - Configurations are sourced from:
    - `crowdsec-patroni-values-7m88ccffdf`
    - `crowdsec-patroni-helmrelease-overrides` (optional)

## Configuration Details

### crowdsec Values
- **Container Runtime**: containerd
- **LAPI Dashboard**: Disabled
- **Agent Environment Variables**:
  - `COLLECTIONS`: "crowdsecurity/http-cve"
  - `CROWDSEC_BYPASS_DB_VOLUME_CHECK`: "TRUE"
- **Resource Limits**:
  - Memory: 500Mi
  - CPU: 800m

### crowdsec-patroni Values
- **PostgreSQL Configuration**:
  - Database: crowdsec
  - User: crowdsec
  - Password: `${crowdsec_database_password}`
- **Replication**:
  - Enabled with specified passwords for superuser and replication.
- **Persistence**: Enabled with a storage request of 4Gi.

## Networking
- **HTTPRoute**: `crowdsec-api`
  - **Hostnames**: crowdsec-api.${domain_absolutist_it:=absolutist.it}
  - **Backend**: crowdsec-service on port 8080

## Image Management
- **Image Repository**: crowdsecurity/crowdsec
- **Image Policy**: Semver range for automatic updates.

This documentation provides a concise overview of the `crowdsec` component deployed in the `nas` cluster, detailing its configuration, dependencies, and networking setup.
