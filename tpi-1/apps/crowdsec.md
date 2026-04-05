---
title: "crowdsec"
parent: "Apps"
grand_parent: "tpi-1"
---

# crowdsec

## Overview
The `crowdsec` component is deployed in the `tpi-1` cluster using Flux for GitOps. It consists of two main Helm releases: `crowdsec` and `crowdsec-patroni`, which work together to provide security monitoring and database management functionalities.

## Helm Releases

### crowdsec--crowdsec
- **Chart**: crowdsec
- **Version**: 0.19.5
- **Repository**: [crowdsec](https://crowdsecurity.github.io/helm-charts)
- **Release Name**: crowdsec
- **Target Namespace**: crowdsec
- **Reconciliation Interval**: 5m
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
- **Reconciliation Interval**: 5m
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
The configuration for `crowdsec` is managed through several ConfigMaps that define various parameters, including database connections, logging settings, and security policies.

### Key Configurations
- **Base Values**: Configures the container runtime and application security settings.
- **Shared Values**: Defines image repository, agent environment variables, and resource limits.
- **Patroni Values**: Manages PostgreSQL settings, including user credentials and replication configurations.

## Networking
The `crowdsec` component exposes its API through an HTTPRoute, allowing access via the hostname `crowdsec-api.${domain_absolutist_it:=absolutist.it}`. This route is managed by the Envoy gateway.

## Image Management
The component utilizes Flux's image management capabilities to track the `crowdsecurity/crowdsec` image, with a reconciliation interval of 24 hours.

## Dependencies
- The `crowdsec` release depends on the `crowdsec-patroni` release, which in turn depends on several other components such as `cert-manager`, `reflector`, and `etcd`.

## Namespace
All resources are deployed in the `crowdsec` namespace, which is specifically created for this component.

## Conclusion
The `crowdsec` component is a robust solution for security monitoring in Kubernetes, leveraging GitOps practices for deployment and management. It integrates with PostgreSQL through Patroni for database management and utilizes Envoy for API routing.
