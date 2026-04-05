---
title: "crowdsec"
parent: "Apps"
grand_parent: "nas"
---

# crowdsec

## Overview
CrowdSec is a security automation tool that provides real-time protection against various threats by analyzing logs and blocking malicious actors. In this deployment, CrowdSec is integrated with a PostgreSQL database managed by Patroni for high availability. This is a multi-component deployment consisting of two HelmReleases: `crowdsec` and `crowdsec-patroni`.

## Sub-components

### HelmRelease: crowdsec--crowdsec
- **Chart**: crowdsec
- **Version**: 0.19.5
- **Repository**: crowdsec (https://crowdsecurity.github.io/helm-charts)
- **Release Name**: crowdsec
- **Target Namespace**: crowdsec
- **Reconciliation Interval**: 5m
- **Dependencies**: crowdsec--crowdsec-patroni
- **Resources Created**: 
  - ConfigMap (6)
  - Service (2)
  - Secret (1)
  - Deployment (1)
  - DaemonSet (1)

### HelmRelease: crowdsec--crowdsec-patroni
- **Chart**: patroni
- **Version**: latest (floating: >=0.1.0-0)
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Release Name**: crowdsec-patroni
- **Target Namespace**: crowdsec
- **Reconciliation Interval**: 5m
- **Dependencies**: cert-manager--cert-manager, reflector--reflector, etcd--etcd
- **Resources Created**: 
  - ConfigMap (5)
  - Service (2)
  - StatefulSet (1)
  - Deployment (1)

## Resources Summary
- **Total Kubernetes Resource Kinds**: 
  - HelmRelease (2)
  - ConfigMap (2)
  - Namespace (1)
  - ImageRepository (1)
  - ImagePolicy (1)
  - HelmRepository (1)
  - HTTPRoute (1)
