---
title: "crowdsec"
parent: "Apps"
grand_parent: "tpi-1"
---

# crowdsec

## Overview
The `crowdsec` component is deployed in the `tpi-1` cluster using Flux and Helm. It consists of two main Helm releases: `crowdsec` and `crowdsec-patroni`, which work together to provide security and database functionalities.

## Helm Repository
The `crowdsec` Helm chart is sourced from the official CrowdSec Helm repository:
- **URL**: [https://crowdsecurity.github.io/helm-charts](https://crowdsecurity.github.io/helm-charts)
- **Update Interval**: 24 hours

## Helm Releases

### crowdsec
- **Release Name**: `crowdsec`
- **Chart Version**: `0.19.5`
- **Namespace**: `crowdsec`
- **Update Interval**: 5 minutes
- **Depends On**: 
  - `crowdsec--crowdsec-patroni`
- **Values Configuration**:
  - Base values are loaded from `crowdsec-values-bc85gb942d` ConfigMap.
  - Shared values are also loaded from the same ConfigMap.
  - Optional values can be overridden using `crowdsec-helmrelease-overrides`.

### crowdsec-patroni
- **Release Name**: `crowdsec-patroni`
- **Chart Version**: `>=0.1.0-0`
- **Namespace**: `crowdsec`
- **Depends On**: 
  - `cert-manager--cert-manager`
  - `reflector--reflector`
  - `etcd--etcd`
- **Values Configuration**:
  - Loaded from `crowdsec-patroni-values-7g4gm6hh48` ConfigMap.
  - Optional overrides can be applied using `crowdsec-patroni-helmrelease-overrides`.

## Kubernetes Resources
The deployment creates the following Kubernetes resources:

- **Namespace**: `crowdsec`
- **HTTPRoute**: `crowdsec-api` for routing traffic to the CrowdSec API.
- **ConfigMaps**: 
  - `crowdsec-values-bc85gb942d` for configuration values.
  - `crowdsec-patroni-values-7g4gm6hh48` for Patroni configuration.
- **ImageRepository**: `crowdsec` for managing the CrowdSec image.
- **ImagePolicy**: `crowdsec` for versioning the CrowdSec image.

## Configuration Details
### crowdsec Configuration
- **Container Runtime**: `containerd`
- **LAPI Configuration**:
  - Dashboard is disabled.
  - Uses a specific image tag for compatibility with ARM architecture.
- **Agent Configuration**:
  - Collects logs from various applications and services.
  - Configures environment variables for database access and enrollment.

### crowdsec-patroni Configuration
- **PostgreSQL Configuration**:
  - Creates a database named `crowdsec` with a user `crowdsec`.
  - Configures SSL for database connections.
- **Replication and High Availability**:
  - Uses Patroni for managing PostgreSQL clusters.
  - Configures Cilium network policies for secure communication between instances.

## Notes
- Ensure that the necessary secrets and environment variables are set for database access and enrollment keys.
- Regularly check the Helm repository for updates to the `crowdsec` and `crowdsec-patroni` charts.
