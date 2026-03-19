---
title: "mail-relay"
parent: "Apps"
grand_parent: "tpi-1"
---

# Mail Relay

## Overview
The `mail-relay` component provides email relay functionality within the `tpi-1` cluster. It is a multi-component deployment consisting of two HelmReleases: `default--mail-relay` for the mail relay service and `default--mail-relay-openldap` for LDAP-based user authentication and configuration. Together, these sub-components enable secure email relay and user management.

## Sub-components
### Mail Relay (`default--mail-relay`)
- **Chart**: `docker-mailserver`
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: `default`
- **Description**: Provides the core mail relay service, including SMTP, submission, and metrics endpoints. It integrates with LDAP for user authentication and configuration.

### OpenLDAP (`default--mail-relay-openldap`)
- **Chart**: `openldap`
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: `default`
- **Description**: Manages LDAP-based user authentication and stores configuration data for the mail relay service.

## Dependencies
The `mail-relay` deployment has the following dependency chain:
1. **`cert-manager--cert-manager`**: Provides certificate management for secure communication.
2. **`default--mail-relay-openldap`**: Depends on `cert-manager` for TLS certificates and provides LDAP services for user authentication.
3. **`default--mail-relay`**: Depends on `default--mail-relay-openldap` for LDAP-based user authentication and configuration.

## Helm Chart(s)
### Mail Relay (`default--mail-relay`)
- **Chart**: `docker-mailserver`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

### OpenLDAP (`default--mail-relay-openldap`)
- **Chart**: `openldap`
- **Repository**: `wahooli` (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **Service (`mail-relay`)**: Exposes the mail relay service with the following ports:
  - `smtp` (TCP/25): Standard SMTP port for email relay.
  - `submissions` (TCP/465): SMTP over SSL.
  - `submission` (TCP/587): SMTP with STARTTLS.
  - `metrics` (TCP/9154): Exposes metrics for monitoring.

### Workloads
- **Deployment (`mail-relay`)**: Runs the mail relay application with one replica. Includes resource limits and requests for memory, CPU, and ephemeral storage. Utilizes init containers for configuration setup and log file creation. A sidecar container (`postfix-exporter`) is included for metrics collection.

- **Deployment (`mail-relay-openldap`)**: Runs the OpenLDAP service with one replica. Includes resource limits and requests for memory and CPU. Utilizes init containers for configuration setup.

### Storage
- **ConfigMaps**:
  - `docker-mailserver-values-t7kt2hmg4k`: Contains Helm values for the mail relay service.
  - `mail-relay-env-fbh87h9kg9`: Provides environment variables for the mail relay service.
  - `mail-relay-config-d7248ht69b`: Contains configuration files for the mail relay service.
  - `mail-relay-ldap-ldifs-4ftdbd86b8`: Stores LDAP LDIF files for user provisioning.
  - `mail-relay-ldap-schemas-67f2b99k4h`: Contains LDAP schema definitions.

- **Persistent Volumes**:
  - `data`: Stores mail logs, state, and configuration files for the mail relay service.
  - `custom-ldif`: Stores custom LDIF files for OpenLDAP.
  - `custom-schemas`: Stores custom LDAP schemas for OpenLDAP.

### Security
- **Certificates**:
  - `mail-relay-certificate`: TLS certificate for the mail relay service.
  - `mail-relay-ldap-certificate`: TLS certificate for the OpenLDAP service.

### Images
- **Mail Relay**:
  - `ghcr.io/docker-mailserver/docker-mailserver:15.1.0`
  - Sidecar: `ghcr.io/wahooli/docker/postfix_exporter:latest`
- **OpenLDAP**:
  - `ghcr.io/wahooli/docker/openldap:2.6.10`

## Configuration Highlights
### Mail Relay
- **Environment Variables**:
  - `OVERRIDE_HOSTNAME`: `mail-relay.default.svc.cluster.local`
  - `SMTP_ONLY`: `"1"` (disables IMAP/POP3)
  - `LDAP_BIND_DN`: `cn=mailserver,ou=users,dc=wahooli,dc=homelab`
  - `LOG_LEVEL`: `warn`

- **Resource Requests and Limits**:
  - Memory: 128Mi (request), 256Mi (limit)
  - CPU: 160m (request)
  - Ephemeral Storage: 200Mi (request), 2048Mi (limit)

- **Persistence**:
  - Configurations and logs are stored in persistent volumes.

### OpenLDAP
- **Environment Variables**:
  - `LDAP_ADMIN_USERNAME` and `LDAP_ADMIN_PASSWORD`: Retrieved from secrets.
  - `LDAP_ROOT`: `dc=wahooli,dc=homelab`
  - TLS settings for secure LDAP communication.

- **Resource Requests and Limits**:
  - Memory: 32Mi (request), 64Mi (limit)
  - CPU: 40m (request)

- **Persistence**:
  - LDIF files and schemas are stored in persistent volumes.

## Deployment
- **Target Namespace**: `default`
- **Release Names**:
  - Mail Relay: `mail-relay`
  - OpenLDAP: `mail-relay-openldap`
- **Reconciliation Interval**: 5 minutes
- **Install/Upgrade Behavior**:
  - Automatic remediation of failed installations.
  - Unlimited retries for installation.
