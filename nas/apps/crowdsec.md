---
title: "crowdsec"
parent: "Apps"
grand_parent: "nas"
---

# crowdsec

## Overview
The `crowdsec` component is deployed in the `nas` cluster using Flux and Helm. It provides security capabilities by leveraging CrowdSec's agent and API functionalities.

## Helm Releases
This deployment consists of two Helm releases:

### 1. crowdsec--crowdsec
- **Chart**: crowdsec
- **Version**: 0.19.5
- **Repository**: [crowdsec](https://crowdsecurity.github.io/helm-charts)
- **Namespace**: `flux-system`
- **Target Namespace**: `crowdsec`
- **Install Interval**: 5 minutes
- **Upgrade Remediation**: Remediate last failure
- **Values Sources**:
  - ConfigMap: `crowdsec-values-9htmkf4mfb` (includes `values-base.yaml`, `values-shared.yaml`, and optional `values.yaml`)
  - ConfigMap: `crowdsec-helmrelease-overrides` (optional)

### 2. crowdsec--crowdsec-patroni
- **Chart**: patroni
- **Version**: `>=0.1.0-0`
- **Repository**: wahooli
- **Namespace**: `flux-system`
- **Target Namespace**: `crowdsec`
- **Install Interval**: 5 minutes
- **Values Sources**:
  - ConfigMap: `crowdsec-patroni-values-7m88ccffdf` (includes `values.yaml`)
  - ConfigMap: `crowdsec-patroni-helmrelease-overrides` (optional)

## Configuration
The configuration for the `crowdsec` component is managed through several ConfigMaps, which define various parameters for the agent and API.

### Key Configurations
- **Container Runtime**: `containerd`
- **LAPI Dashboard**: Disabled
- **Agent Environment Variables**:
  - `COLLECTIONS`: `"crowdsecurity/http-cve"`
  - `DB_PASSWORD`: `${crowdsec_database_password}`
- **Database Configuration**:
  - Type: `postgresql`
  - User: `crowdsec`
  - Database Name: `crowdsec`
  - Host: `crowdsec-patroni-proxy.crowdsec.svc.cluster.local`
  - Port: `5432`
  
### HTTPRoute
An `HTTPRoute` resource is defined to expose the CrowdSec API:
- **Name**: `crowdsec-api`
- **Hostnames**: `crowdsec-api.${domain_absolutist_it:=absolutist.it}`
- **Backend Reference**: `crowdsec-service` on port `8080`

## Dependencies
The `crowdsec` Helm release depends on the `crowdsec--crowdsec-patroni` release, which manages the PostgreSQL database for CrowdSec.

## Namespace
All resources are deployed in the `crowdsec` namespace, which is created with specific annotations to manage pruning and service accounts.

## Image Management
The component uses the `crowdsecurity/crowdsec` image, with an image policy defined to manage updates based on semantic versioning.

## Notes
- Ensure that the necessary environment variables are set for database connectivity and agent configuration.
- The deployment includes specific configurations for security and logging, which should be reviewed and adjusted as necessary for your environment.
