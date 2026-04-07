---
title: "crowdsec"
parent: "Apps"
grand_parent: "nas"
---

# crowdsec

The `crowdsec` component is deployed in the `nas` cluster using Flux for GitOps management. It consists of multiple Helm releases that manage the deployment of the CrowdSec application and its dependencies.

## Helm Repository

The Helm charts for CrowdSec are sourced from the official CrowdSec Helm repository:

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

The main CrowdSec application is deployed using the HelmRelease resource:

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
      version: 0.19.5
      sourceRef:
        kind: HelmRepository
        name: crowdsec
        namespace: flux-system
  install:
    timeout: 5m
  interval: 5m
  releaseName: crowdsec
  targetNamespace: crowdsec
  valuesFrom:
  - kind: ConfigMap
    name: crowdsec-values-m4khbh5fm2
    valuesKey: values-base.yaml
  - kind: ConfigMap
    name: crowdsec-values-m4khbh5fm2
    valuesKey: values-shared.yaml
  - kind: ConfigMap
    name: crowdsec-values-m4khbh5fm2
    optional: true
    valuesKey: values.yaml
  - kind: ConfigMap
    name: crowdsec-helmrelease-overrides
    optional: true
    valuesKey: values.yaml
```

### crowdsec-patroni

CrowdSec relies on a PostgreSQL database managed by Patroni, which is also deployed as a HelmRelease:

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
      version: '>=0.1.0-0'
      sourceRef:
        kind: HelmRepository
        name: wahooli
        namespace: flux-system
  install:
    remediation:
      retries: -1
  interval: 5m
  releaseName: crowdsec-patroni
  targetNamespace: crowdsec
  valuesFrom:
  - kind: ConfigMap
    name: crowdsec-patroni-values-7m88ccffdf
    valuesKey: values.yaml
  - kind: ConfigMap
    name: crowdsec-patroni-helmrelease-overrides
    optional: true
    valuesKey: values.yaml
```

## Configuration

The configuration for CrowdSec is managed through ConfigMaps, which include base values, shared values, and optional overrides. Key configurations include:

- **Container Runtime**: Set to `containerd`.
- **API Configuration**: The API server is configured to use forwarded headers and trusted proxies.
- **Database Configuration**: PostgreSQL connection details are provided, including SSL certificates for secure connections.

### Example ConfigMap Values

```yaml
data:
  values-base.yaml: |
    container_runtime: containerd
    appsec:
      enabled: false
    lapi:
      dashboard:
        enabled: false
        image:
          tag: v0.55.9.4
    config:
      agent_config.yaml.local: |
        common:
          log_media: stdout
          log_format: json
          log_level: warn
```

## Networking

An HTTPRoute resource is defined to expose the CrowdSec API:

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

## Image Management

The CrowdSec image is managed through Flux's ImageRepository and ImagePolicy resources:

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

## Summary

The `crowdsec` component is a critical part of the security infrastructure in the `nas` cluster, providing automated threat detection and response capabilities. It is deployed using Flux with a focus on GitOps principles, ensuring that the deployment is reproducible and manageable through version-controlled configurations.
