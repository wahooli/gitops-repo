---
title: "crowdsec"
parent: "Apps"
grand_parent: "nas"
---

# crowdsec

The `crowdsec` component is deployed in the `nas` cluster using Flux and Helm. It consists of two main Helm releases: `crowdsec` and `crowdsec-patroni`, which work together to provide security and database management functionalities.

## Helm Repository

The Helm charts for `crowdsec` are sourced from the following repository:

- **Name**: crowdsec
- **URL**: [https://crowdsecurity.github.io/helm-charts](https://crowdsecurity.github.io/helm-charts)
- **Update Interval**: 24 hours

## Helm Releases

### crowdsec

- **Release Name**: crowdsec
- **Chart Version**: 0.19.5
- **Target Namespace**: crowdsec
- **Update Interval**: 5 minutes
- **Dependencies**: 
  - `crowdsec--crowdsec-patroni`
- **ConfigMaps Used for Values**:
  - `crowdsec-values-fg8c96t495` (base and shared values)
  - `crowdsec-helmrelease-overrides` (optional)

#### Key Configuration Values

- **Container Runtime**: containerd
- **LAPI Dashboard**: Disabled
- **Agent Environment Variables**:
  - `COLLECTIONS`: crowdsecurity/http-cve
  - `CROWDSEC_BYPASS_DB_VOLUME_CHECK`: TRUE
- **Resource Limits**:
  - Memory: 500Mi
  - CPU: 800m

### crowdsec-patroni

- **Release Name**: crowdsec-patroni
- **Chart Version**: >=0.1.0-0
- **Target Namespace**: crowdsec
- **Dependencies**:
  - `cert-manager`
  - `reflector`
  - `etcd`
- **ConfigMaps Used for Values**:
  - `crowdsec-patroni-values-7m88ccffdf`
  - `crowdsec-patroni-helmrelease-overrides` (optional)

#### Key Configuration Values

- **PostgreSQL Configuration**:
  - Database Name: crowdsec
  - Username: crowdsec
  - Password: `${crowdsec_database_password}`
- **Patroni Settings**:
  - Replica Count: 1
  - SSL: Enabled
  - Superuser Password: `${crowdsec_postgres_superuser_password}`
  - Replication Password: `${crowdsec_postgres_replication_password}`

## Networking

### HTTPRoute

An HTTPRoute is configured to expose the `crowdsec` API:

- **Name**: crowdsec-api
- **Hostnames**: crowdsec-api.absolutist.it
- **Backend Reference**: crowdsec-service on port 8080

## Image Management

### Image Repository

- **Name**: crowdsec
- **Image**: crowdsecurity/crowdsec
- **Update Interval**: 24 hours

### Image Policy

- **Name**: crowdsec
- **Policy**: Semantic versioning range

## Namespace

The `crowdsec` component is deployed in its own namespace:

- **Namespace Name**: crowdsec
- **Annotations**: 
  - `kustomize.toolkit.fluxcd.io/prune`: disabled

This documentation provides a comprehensive overview of the `crowdsec` deployment in the `nas` cluster, detailing its configuration, dependencies, and networking setup.
