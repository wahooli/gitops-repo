---
title: "crowdsec"
parent: "Apps"
grand_parent: "tpi-1"
---

# crowdsec

## Overview
The `crowdsec` component is deployed in the `tpi-1` cluster using Flux CD for GitOps management. It leverages a Helm chart to manage its lifecycle and configuration.

## Helm Repository
- **Name**: crowdsec
- **URL**: [https://crowdsecurity.github.io/helm-charts](https://crowdsecurity.github.io/helm-charts)
- **Update Interval**: 24 hours

## Helm Releases
### crowdsec
- **Release Name**: crowdsec
- **Chart Version**: 0.19.5
- **Namespace**: crowdsec
- **Install Interval**: 5 minutes
- **Timeout**: 5 minutes
- **Remediation**: Retries indefinitely on failure
- **Values**: Configurations are sourced from multiple ConfigMaps:
  - `crowdsec-values-k6mhm75d8k` (base and shared values)
  - `crowdsec-helmrelease-overrides` (optional)

### crowdsec-patroni
- **Release Name**: crowdsec-patroni
- **Chart Version**: latest (>=0.1.0-0)
- **Namespace**: crowdsec
- **Install Interval**: 5 minutes
- **Remediation**: Retries indefinitely on failure
- **Values**: Configurations are sourced from ConfigMaps:
  - `crowdsec-patroni-values-7g4gm6hh48`
  - `crowdsec-patroni-helmrelease-overrides` (optional)

## Kubernetes Resources
### Namespace
- **Name**: crowdsec
- **Annotations**: 
  - `kustomize.toolkit.fluxcd.io/prune`: disabled
  - `kustomize.toolkit.fluxcd.io/ssa`: merge

### HTTPRoute
- **Name**: crowdsec-api
- **Namespace**: crowdsec
- **Hostnames**: crowdsec-api.${domain_absolutist_it:=absolutist.it}
- **Backend Reference**: crowdsec-service on port 8080

### ConfigMaps
- **crowdsec-values-k6mhm75d8k**: Contains base and shared configuration values for the `crowdsec` release.
- **crowdsec-patroni-values-7g4gm6hh48**: Contains configuration values for the `crowdsec-patroni` release.

### Image Repository
- **Name**: crowdsec
- **Image**: crowdsecurity/crowdsec
- **Update Interval**: 24 hours

### Image Policy
- **Name**: crowdsec
- **Policy**: Semantic versioning range specified.

## Configuration Highlights
### crowdsec
- **Container Runtime**: containerd
- **LAPI Configuration**: 
  - Dashboard disabled
  - Replicas: 1
  - Resource limits: 500Mi memory, 800m CPU
- **Database Configuration**: Uses PostgreSQL with SSL.

### crowdsec-patroni
- **PostgreSQL Configuration**: 
  - Database: crowdsec
  - User: crowdsec
  - Password: sourced from environment variables.
- **Replication**: Enabled with specific user permissions.
- **Backup Configuration**: Weekly and daily backups enabled.

## Dependencies
- The `crowdsec` HelmRelease depends on the `crowdsec-patroni` release for database management.
- The `crowdsec-patroni` release has dependencies on other components like `cert-manager`, `reflector`, and `etcd`.

This documentation provides a concise overview of the `crowdsec` component deployed in the `tpi-1` cluster, detailing its configuration, dependencies, and Kubernetes resources.
