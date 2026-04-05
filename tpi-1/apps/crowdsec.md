---
title: "crowdsec"
parent: "Apps"
grand_parent: "tpi-1"
---

# crowdsec

## Overview
The `crowdsec` component is deployed in the `tpi-1` cluster using Flux for GitOps. It consists of two main Helm releases: `crowdsec` and `crowdsec-patroni`, which work together to provide security and database management functionalities.

## Helm Releases

### crowdsec--crowdsec
- **Chart**: crowdsec
- **Version**: 0.19.5
- **Repository**: [crowdsec](https://crowdsecurity.github.io/helm-charts)
- **Release Name**: crowdsec
- **Target Namespace**: crowdsec
- **Reconciliation Interval**: 5 minutes
- **Dependencies**: 
  - `crowdsec--crowdsec-patroni`

#### Rendered Kubernetes Resources
- ConfigMap: 6
- Service: 2
- Secret: 1
- Deployment: 1
- DaemonSet: 1

### crowdsec--crowdsec-patroni
- **Chart**: patroni
- **Version**: latest (floating: >=0.1.0-0)
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Release Name**: crowdsec-patroni
- **Target Namespace**: crowdsec
- **Reconciliation Interval**: 5 minutes
- **Dependencies**: 
  - `cert-manager--cert-manager`
  - `reflector--reflector`
  - `etcd--etcd`

#### Rendered Kubernetes Resources
- ConfigMap: 5
- Service: 2
- StatefulSet: 1
- Deployment: 1

## Configuration
The configuration for the `crowdsec` component is primarily managed through ConfigMaps, which include various YAML files for base and shared values. Key configurations include:

- **Container Runtime**: `containerd`
- **LAPI Dashboard**: Disabled by default
- **Agent Configuration**: Includes environment variables for collections and database connection.
- **Database Configuration**: Uses PostgreSQL with SSL settings.

## Networking
The `crowdsec` component exposes an HTTP route for the API:
- **HTTPRoute Name**: crowdsec-api
- **Hostnames**: crowdsec-api.${domain_absolutist_it:=absolutist.it}
- **Backend**: crowdsec-service on port 8080

## Image Management
- **Image Repository**: crowdsecurity/crowdsec
- **Image Policy**: Managed with a semver range.

## Dependencies
The `crowdsec` release depends on the `crowdsec-patroni` release, which in turn depends on several other components including `cert-manager`, `reflector`, and `etcd`. This hierarchical dependency ensures that the database and other services are available for the `crowdsec` application to function correctly.

## Notes
- The deployment is configured to automatically reconcile every 5 minutes.
- The `crowdsec` component is designed to enhance security by monitoring and responding to threats in real-time.
