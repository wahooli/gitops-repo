---
title: "crowdsec"
parent: "Apps"
grand_parent: "tpi-1"
---

# crowdsec

The `crowdsec` component is deployed in the `tpi-1` cluster using Flux and Helm. It consists of two main Helm releases: `crowdsec` and `crowdsec-patroni`, which work together to provide security and database functionalities.

## Helm Repository

The `crowdsec` Helm chart is sourced from the official CrowdSec Helm repository:

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

## Helm Releases

### crowdsec

- **Chart Version**: 0.19.5
- **Release Name**: `crowdsec`
- **Target Namespace**: `crowdsec`
- **Installation Interval**: 5 minutes
- **Dependencies**: Depends on `crowdsec--crowdsec-patroni`

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: crowdsec--crowdsec
  namespace: flux-system
spec:
  chart:
    spec:
      chart: crowdsec
      sourceRef:
        kind: HelmRepository
        name: crowdsec
        namespace: flux-system
  install:
    timeout: 5m
  valuesFrom:
  - kind: ConfigMap
    name: crowdsec-values-5bb57dc587
    valuesKey: values-base.yaml
  - kind: ConfigMap
    name: crowdsec-values-5bb57dc587
    valuesKey: values-shared.yaml
```

### crowdsec-patroni

- **Chart Version**: latest (>=0.1.0-0)
- **Release Name**: `crowdsec-patroni`
- **Target Namespace**: `crowdsec`
- **Installation Interval**: 5 minutes
- **Dependencies**: Depends on `cert-manager`, `reflector`, and `etcd`

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: crowdsec--crowdsec-patroni
  namespace: flux-system
spec:
  chart:
    spec:
      chart: patroni
      sourceRef:
        kind: HelmRepository
        name: wahooli
        namespace: flux-system
  install:
    remediation:
      retries: -1
```

## Configuration

The configuration for `crowdsec` is managed through several ConfigMaps, which include base values, shared values, and optional overrides. Key configurations include:

- **Container Runtime**: `containerd`
- **LAPI Dashboard**: Disabled
- **Agent Environment Variables**: Includes `COLLECTIONS`, `CROWDSEC_BYPASS_DB_VOLUME_CHECK`, and database credentials.
- **Database Configuration**: Uses PostgreSQL with SSL enabled.

### Example ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: crowdsec-values-5bb57dc587
  namespace: flux-system
data:
  values-base.yaml: |
    container_runtime: containerd
    appsec:
      enabled: false
    lapi:
      dashboard:
        enabled: false
  values-shared.yaml: |
    image:
      repository: crowdsecurity/crowdsec
      pullPolicy: IfNotPresent
```

## Networking

The `crowdsec` component exposes an API through an `HTTPRoute` resource, which routes traffic to the `crowdsec-service` on port 8080.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: crowdsec-api
  namespace: crowdsec
spec:
  hostnames:
  - crowdsec-api.absolutist.it
  rules:
  - backendRefs:
    - name: crowdsec-service
      port: 8080
```

## Image Management

The `crowdsec` component uses Flux's image management capabilities to track the `crowdsecurity/crowdsec` image, with an update interval of 24 hours.

```yaml
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImageRepository
metadata:
  name: crowdsec
  namespace: flux-system
spec:
  image: crowdsecurity/crowdsec
  interval: 24h
```

## Conclusion

The `crowdsec` deployment in the `tpi-1` cluster is configured for security monitoring and database management, leveraging Helm and Flux for continuous delivery and management. The configuration is flexible and can be adjusted through the associated ConfigMaps.
