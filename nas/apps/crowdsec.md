---
title: "crowdsec"
parent: "Apps"
grand_parent: "nas"
---

# CrowdSec

CrowdSec is deployed in the `nas` cluster using FluxCD and Helm. It consists of two HelmReleases: `crowdsec--crowdsec` and `crowdsec--crowdsec-patroni`, which together provide the main CrowdSec application and its PostgreSQL backend.

---

## HelmRelease: `crowdsec--crowdsec`

### Chart Information
- **Chart Name:** `crowdsec`
- **Version:** `0.19.5`
- **Repository:** [CrowdSec Helm Charts](https://crowdsecurity.github.io/helm-charts)
- **Release Name:** `crowdsec`
- **Target Namespace:** `crowdsec`
- **Reconciliation Interval:** 5 minutes
- **Dependencies:** `crowdsec--crowdsec-patroni`

### Kubernetes Resources
This HelmRelease creates the following Kubernetes resources:
- **ConfigMaps:** 6
- **Services:** 2
- **Secrets:** 1
- **Deployments:** 1
- **DaemonSets:** 1

### Configuration
The deployment is configured using multiple ConfigMaps:
- `crowdsec-values-fg7ffm5ctk`:
  - Contains base, shared, and optional values for the CrowdSec application.
  - Includes configurations for the agent, acquisition methods, and scenarios.
- `crowdsec-helmrelease-overrides`:
  - Provides optional overrides for Helm values.

#### Key Features
- **Container Runtime:** Configured for `containerd`.
- **Agent Acquisition:** Monitors specific namespaces and pods for logs, including:
  - `ingress-nginx-controller-*` in `ingress-nginx` namespace.
  - `authentik-server-*` in `authentik` namespace.
  - `mc-router-*` in `default` namespace.
- **LAPI Configuration:**
  - Dashboard disabled.
  - Custom image tag `v0.55.9.4` for ARM64 compatibility.
  - Environment variables for enrollment and database connection.
- **Custom Scenarios and Parsers:** Includes custom YAML configurations for detecting WordPress scanners, secret scanners, and generic PHP scanners.

---

## HelmRelease: `crowdsec--crowdsec-patroni`

### Chart Information
- **Chart Name:** `patroni`
- **Version:** `latest` (floating version)
- **Repository:** Wahooli Helm Charts
- **Release Name:** `crowdsec-patroni`
- **Target Namespace:** `crowdsec`
- **Reconciliation Interval:** 5 minutes
- **Dependencies:** 
  - `cert-manager--cert-manager`
  - `reflector--reflector`
  - `etcd--etcd`

### Kubernetes Resources
This HelmRelease creates the following Kubernetes resources:
- **ConfigMaps:** Multiple for backup scripts and environment variables.
- **Secrets:** Includes TLS certificates and database credentials.
- **Services:** Configured for Patroni and PgBouncer.
- **Deployments:** Patroni and PgBouncer instances.
- **Persistent Volumes:** For database storage and backups.

### Configuration
The deployment is configured using the `crowdsec-patroni-values-7m88ccffdf` ConfigMap:
- **PostgreSQL Configuration:**
  - Database: `crowdsec`
  - User: `crowdsec`
  - Password: `${crowdsec_database_password}`
  - SSL enabled with certificates.
- **Replication:** Configured with 2 replicas and Patroni settings for high availability.
- **PgBouncer:** Connection pooling enabled with custom environment variables.
- **Persistence:** Volumes for database data, backup scripts, and backups.

#### Key Features
- **TLS Support:** Certificates managed via `ClusterIssuer`.
- **Etcd Integration:** Configured for high availability using Etcd.
- **Backup and Restore:** Scripts for pre-backup and restore hooks integrated with Velero annotations.
- **Cilium Network Policies:** Fine-grained network policies for Patroni and PgBouncer communication.

---

## HTTPRoute: `crowdsec-api`

### Configuration
- **Hostname:** `crowdsec-api.${domain_absolutist_it:=absolutist.it}`
- **Parent Gateway:** `internal-gw` in the `infrastructure` namespace.
- **Backend Service:** `crowdsec-service` on port `8080`.

---

## Image Management

### ImageRepository: `crowdsec`
- **Image:** `crowdsecurity/crowdsec`
- **Interval:** 24 hours

### ImagePolicy: `crowdsec`
- **Policy:** Semantic versioning (`vx.x.x`)

---

## Namespace: `crowdsec`

The `crowdsec` namespace is created with the following annotations and labels:
- **Annotations:**
  - `kustomize.toolkit.fluxcd.io/prune: disabled`
  - `kustomize.toolkit.fluxcd.io/ssa: merge`
- **Labels:**
  - `internal-services: true`
  - `velero.io/exclude-from-backup: true`

---

## Summary

The CrowdSec deployment in the `nas` cluster provides a robust security solution with:
- A main application (`crowdsec--crowdsec`) for log acquisition and threat detection.
- A PostgreSQL backend (`crowdsec--crowdsec-patroni`) for data storage and high availability.
- Custom scenarios and parsers for enhanced threat detection.
- Secure communication using TLS and network policies.
- Integration with Velero for backup and restore operations.
