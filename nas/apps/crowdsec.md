---
title: "crowdsec"
parent: "Apps"
grand_parent: "nas"
---

# crowdsec

The `crowdsec` component is deployed in the `nas` cluster using Flux for GitOps. It consists of two main Helm releases: `crowdsec` and `crowdsec-patroni`, which work together to provide security and database functionalities.

## Helm Releases

### crowdsec

- **Chart**: crowdsec
- **Version**: 0.19.5
- **Repository**: [crowdsec](https://crowdsecurity.github.io/helm-charts)
- **Namespace**: `crowdsec`
- **Release Name**: `crowdsec`
- **Install Interval**: 5 minutes
- **Upgrade Remediation**: Remediate last failure

#### Configuration Values

The configuration for the `crowdsec` release is sourced from multiple ConfigMaps:

1. **Base Values** (`values-base.yaml`):
   - Container Runtime: `containerd`
   - LAPI Dashboard: Disabled
   - Logging Configuration: JSON format, warning level

2. **Shared Values** (`values-shared.yaml`):
   - Image Repository: `crowdsecurity/crowdsec`
   - Agent Environment Variables: Includes `COLLECTIONS`, `CROWDSEC_BYPASS_DB_VOLUME_CHECK`, and database connection details.

3. **Custom Values** (`values.yaml`):
   - Image Tag: `v1.7.7`
   - Agent Acquisition Configuration: Monitors various namespaces and pods for security events.

### crowdsec-patroni

- **Chart**: patroni
- **Version**: `>=0.1.0-0`
- **Namespace**: `crowdsec`
- **Release Name**: `crowdsec-patroni`
- **Install Interval**: 5 minutes

#### Configuration Values

The configuration for the `crowdsec-patroni` release includes:

- **Global Patroni Configuration**:
  - PGBouncer enabled
  - Cluster settings with replica count and database initialization parameters.

- **PostgreSQL Configuration**:
  - Database name: `crowdsec`
  - User: `crowdsec`
  - Password: Configured via environment variable.

- **Persistence**:
  - Persistent volume for PostgreSQL data is enabled with a storage request of 4Gi.

## Networking

An `HTTPRoute` resource is defined to expose the `crowdsec` API:

- **Hostname**: `crowdsec-api.${domain_absolutist_it:=absolutist.it}`
- **Backend Reference**: Points to the `crowdsec-service` on port `8080`.

## Image Management

- **Image Repository**: `crowdsecurity/crowdsec`
- **Image Policy**: Managed with a semantic versioning policy.

## Namespace

The `crowdsec` component is deployed in its own namespace, ensuring isolation and management of resources specific to this application.

## Dependencies

The `crowdsec` release depends on the `crowdsec-patroni` release, which manages the PostgreSQL database necessary for the application to function.

This documentation provides an overview of the `crowdsec` deployment, its configuration, and its operational context within the Kubernetes cluster.
