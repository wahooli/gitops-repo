---
title: "mail-relay"
parent: "Apps"
grand_parent: "tpi-1"
---

# mail-relay

## Overview
The `mail-relay` component is a mail server deployment that utilizes Docker Mailserver and OpenLDAP to provide email relay services within the Kubernetes cluster `tpi-1`. This deployment consists of two Helm releases, enabling both the mail server functionality and the LDAP directory service for user authentication.

## Sub-components
### HelmRelease: default--mail-relay
- **Chart**: docker-mailserver
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: A mail relay service that handles SMTP requests and integrates with LDAP for user management.

### HelmRelease: default--mail-relay-openldap
- **Chart**: openldap
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: An LDAP service for user authentication and management, supporting the mail relay functionality.

## Dependencies
- `default--mail-relay` depends on `default--mail-relay-openldap`, which provides the LDAP service necessary for user authentication.
- `default--mail-relay-openldap` depends on `cert-manager--cert-manager`, which is responsible for managing TLS certificates for secure communication.

## Helm Chart(s)
- **docker-mailserver**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: latest (floating: >=0.1.1-0)

- **openldap**
  - **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
  - **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **Service**: Exposes the mail relay and OpenLDAP services, allowing communication over SMTP (ports 25, 465, 587) and metrics (port 9154).
- **ServiceAccount**: Provides an identity for the mail relay and OpenLDAP deployments to interact with the Kubernetes API.

### Storage
- **ConfigMap**: Stores configuration data for both the mail relay and OpenLDAP, including environment variables and LDAP schemas.

### Security
- **Certificate**: Manages TLS certificates for secure communication with the mail relay and OpenLDAP services.

### Workload
- **Deployment**: Manages the lifecycle of the mail relay and OpenLDAP pods, ensuring the desired number of replicas are running and handling updates.

## Configuration Highlights
- **Resource Requests/Limits**: 
  - Mail relay: Requests 160m CPU and 128Mi memory; limits 2048Mi ephemeral storage and 256Mi memory.
  - OpenLDAP: Requests 100m CPU and 64Mi memory; limits 64Mi memory.
- **Persistence**: Both components have persistent storage enabled for configuration and data.
- **Replica Counts**: Both deployments are configured to run a single replica.
- **Important Helm Values**:
  - Mail relay environment variables include `OVERRIDE_HOSTNAME`, `LDAP_SERVER_HOST`, and `SASLAUTHD_LDAP_BIND_DN`.
  - OpenLDAP environment variables include `LDAP_ADMIN_USERNAME` and `LDAP_ADMIN_PASSWORD`.

## Deployment
- **Target Namespace(s)**: default
- **Release Name(s)**: mail-relay, mail-relay-openldap
- **Reconciliation Interval**: 5 minutes for both releases.
- **Install/Upgrade Behavior**: The deployments are configured to remediate last failures and retry indefinitely on failure.
