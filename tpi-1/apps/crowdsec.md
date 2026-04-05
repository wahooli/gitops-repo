---
title: "crowdsec"
parent: "Apps"
grand_parent: "tpi-1"
---

# crowdsec

The `crowdsec` component is deployed in the `tpi-1` cluster and consists of two Helm releases: `crowdsec` and `crowdsec-patroni`. This deployment utilizes the CrowdSec security automation tool and is configured to monitor and respond to potential threats.

## Helm Releases

### crowdsec--crowdsec
- **Chart**: crowdsec
- **Version**: 0.19.5
- **Repository**: [crowdsec](https://crowdsecurity.github.io/helm-charts)
- **Release Name**: crowdsec
- **Target Namespace**: crowdsec
- **Reconciliation Interval**: 5 minutes
- **Dependencies**: 
  - crowdsec--crowdsec-patroni

#### Rendered Kubernetes Resources
- ConfigMap: 6
- Service: 2
- Secret: 1
- Deployment: 1
- DaemonSet: 1

### crowdsec--crowdsec-patroni
- **Chart**: patroni
- **Version**: latest (floating: >=0.1.0-0)
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Release Name**: crowdsec-patroni
- **Target Namespace**: crowdsec
- **Reconciliation Interval**: 5 minutes
- **Dependencies**: 
  - cert-manager--cert-manager
  - reflector--reflector
  - etcd--etcd

#### Rendered Kubernetes Resources
- ConfigMap: 5
- Service: 2
- StatefulSet: 1
- Deployment: 1

## Configuration

### Namespace
The `crowdsec` component is deployed in its own namespace:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: crowdsec
```

### Helm Repository
The Helm repository for CrowdSec charts is defined as follows:
```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: crowdsec
  namespace: flux-system
spec:
  interval: 24h
  url: https://crowdsecurity.github.io/helm-charts
```

### Values Configuration
The configuration for the `crowdsec` Helm release is sourced from multiple ConfigMaps, including:
- `crowdsec-values-2dtt7f994d` (base and shared values)
- `crowdsec-helmrelease-overrides` (optional overrides)

#### Example Configuration Snippet
```yaml
values-base.yaml:
  container_runtime: containerd
  appsec:
    enabled: false
  lapi:
    dashboard:
      enabled: false
```

### HTTPRoute
An HTTPRoute is configured to expose the CrowdSec API:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: crowdsec-api
  namespace: crowdsec
spec:
  hostnames:
  - crowdsec-api.absolutist.it
  parentRefs:
  - name: envoy-gw-private
    namespace: envoy-gateway-system
  rules:
  - backendRefs:
    - name: crowdsec-service
      port: 8080
```

## Summary
The `crowdsec` deployment in the `tpi-1` cluster is designed to enhance security by monitoring and responding to threats using the CrowdSec tool. It consists of a primary Helm release for the application and a secondary release for managing the PostgreSQL database with Patroni. The deployment is configured to ensure high availability and resilience through its various Kubernetes resources.
