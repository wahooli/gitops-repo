---
title: "crowdsec"
parent: "Apps"
grand_parent: "tpi-1"
---

# CrowdSec

The CrowdSec component is deployed in the `tpi-1` Kubernetes cluster using the Flux GitOps framework. It consists of two primary HelmReleases: `crowdsec` and `crowdsec-patroni`. Below are the details of the deployment.

---

## Overview

CrowdSec is an open-source and collaborative cybersecurity solution that leverages a behavior analysis engine to detect and respond to malicious activities. It is deployed using Helm charts and managed by Flux.

---

## HelmReleases

### 1. `crowdsec--crowdsec`

#### Chart Information
- **Chart Name**: `crowdsec`
- **Version**: `0.19.5`
- **Repository**: [CrowdSec Helm Charts](https://crowdsecurity.github.io/helm-charts)

#### Namespace
- **Target Namespace**: `crowdsec`

#### Dependencies
- Depends on: `crowdsec--crowdsec-patroni`

#### Configuration
The `crowdsec--crowdsec` HelmRelease is configured using multiple ConfigMaps:
- **`crowdsec-values-28h4686fbk`**:
  - `values-base.yaml`: Contains base configurations such as container runtime, application security settings, and logging configurations.
  - `values-shared.yaml`: Defines shared configurations like image repository, agent acquisition settings, and environment variables.
  - `values.yaml`: Specifies additional configurations, including the image tag (`v1.7.6`), agent acquisition for various namespaces, and parser/scenario configurations.
- **`crowdsec-helmrelease-overrides`** (optional): Provides additional overrides for the HelmRelease.

#### Key Features
- **Agent Configuration**:
  - Monitors pods in specific namespaces (`ingress-nginx`, `authentik`, `default`) for security events.
  - Supports custom parsers and scenarios for detecting and mitigating threats.
- **LAPI (Local API)**:
  - Configurable replicas (default: 1).
  - Persistent volume support for configuration and data storage (disabled by default).
  - Environment variables for enrollment and database credentials.
- **HTTPRoute**:
  - Exposes the CrowdSec API via the hostname `crowdsec-api.${domain_absolutist_it:=absolutist.it}`.
  - Uses the `internal-gw` Gateway in the `infrastructure` namespace.

---

### 2. `crowdsec--crowdsec-patroni`

#### Chart Information
- **Chart Name**: `patroni`
- **Version**: Floating (`>=0.1.0-0`)
- **Repository**: Wahooli Helm Charts

#### Namespace
- **Target Namespace**: `crowdsec`

#### Dependencies
- Depends on:
  - `cert-manager--cert-manager`
  - `reflector--reflector`
  - `etcd--etcd`

#### Configuration
The `crowdsec--crowdsec-patroni` HelmRelease is configured using the following ConfigMaps:
- **`crowdsec-patroni-values-7g4gm6hh48`**:
  - Contains configurations for PostgreSQL, Patroni, and related components.
  - Includes database bootstrap settings, SSL configurations, and persistence options.
- **`crowdsec-patroni-helmrelease-overrides`** (optional): Provides additional overrides for the HelmRelease.

#### Key Features
- **PostgreSQL Database**:
  - Uses Patroni for high availability and replication.
  - Configured with a single replica and a bootstrap database named `crowdsec`.
  - Supports SSL connections with certificates stored in Kubernetes secrets.
- **PgBouncer**:
  - Connection pooling enabled with customizable environment variables.
- **Cilium Network Policies**:
  - Enforces network security for Patroni and related components.
- **Persistence**:
  - Persistent storage for PostgreSQL data and backup scripts.
  - Supports backup and restore hooks with Velero annotations.

---

## Image Management

- **ImageRepository**: `crowdsecurity/crowdsec`
- **ImagePolicy**: Semantic versioning (`vx.x.x`) is used to automatically update the image to the latest compatible version.

---

## Networking

- **HTTPRoute**:
  - Exposes the CrowdSec API at `crowdsec-api.${domain_absolutist_it:=absolutist.it}`.
  - Routes traffic through the `internal-gw` Gateway in the `infrastructure` namespace.

---

## Additional Notes

- The CrowdSec deployment is tightly integrated with other cluster components, such as `cert-manager`, `etcd`, and `reflector`.
- Custom parsers and scenarios are defined to enhance the detection of specific threats, such as WordPress vulnerability scanners and generic PHP scanners.
- The deployment uses advanced configurations, including TLS for PostgreSQL and network policies for secure communication.

For more information, refer to the [CrowdSec documentation](https://docs.crowdsec.net/) and the [Patroni documentation](https://patroni.readthedocs.io/).
