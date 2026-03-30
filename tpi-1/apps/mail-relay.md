---
title: "mail-relay"
parent: "Apps"
grand_parent: "tpi-1"
---

# mail-relay

## Overview
The `mail-relay` component is a mail server relay solution deployed in the `tpi-1` cluster. It utilizes the `docker-mailserver` Helm chart to provide email relay capabilities, including SMTP services. This deployment consists of multiple Helm releases, with the primary focus on the `mail-relay` service and its dependency on an OpenLDAP service for user authentication.

## Sub-components
### HelmRelease: default--mail-relay
- **Chart**: docker-mailserver
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: SMTP relay services, including user authentication via LDAP.

### HelmRelease: default--mail-relay-openldap
- **Chart**: openldap
- **Version**: latest (floating: >=0.1.1-0)
- **Target Namespace**: default
- **Provides**: LDAP services for user management and authentication.

## Dependencies
- **default--mail-relay** depends on **default--mail-relay-openldap**: This dependency provides the LDAP service required for user authentication in the mail relay.
- **default--mail-relay-openldap** depends on **cert-manager--cert-manager**: This dependency manages TLS certificates for secure communication.

## Helm Chart(s)
### default--mail-relay
- **Chart**: docker-mailserver
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

### default--mail-relay-openldap
- **Chart**: openldap
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **Service**: Exposes the mail relay service on ports 25 (SMTP), 465 (submissions), and 587 (submission). This allows external clients to connect and send emails through the relay.
- **ServiceAccount**: Provides an identity for processes that run in a Pod, allowing them to interact with the Kubernetes API.

### Storage
- **ConfigMap**: Stores configuration data for the mail relay and OpenLDAP services, including environment variables and LDAP schemas.

### Security
- **Certificate**: Manages TLS certificates for secure communication with the mail relay and OpenLDAP services.

## Configuration Highlights
- **Resource Requests/Limits**: The mail relay is configured with memory limits of 256Mi and requests of 128Mi, while the OpenLDAP service has memory limits of 64Mi and requests of 32Mi.
- **Persistence**: Both components utilize persistent storage for data retention, with the mail relay storing logs and state data.
- **Replica Count**: The mail relay is set to run with a single replica.
- **Important Helm Values**: 
  - `OVERRIDE_HOSTNAME`: Configured to `mail-relay.default.svc.cluster.local`.
  - `LDAP_SERVER_HOST`: Points to the OpenLDAP service for authentication.

## Deployment
- **Target Namespace**: default
- **Release Names**: mail-relay, mail-relay-openldap
- **Reconciliation Interval**: 5 minutes for both releases.
- **Install/Upgrade Behavior**: The installation is configured to remediate the last failure automatically and retry indefinitely.
