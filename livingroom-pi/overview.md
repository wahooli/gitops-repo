---
title: "livingroom-pi"
has_children: true
---

# livingroom-pi

## Overview
The `livingroom-pi` cluster is a Kubernetes environment managed using GitOps principles with Flux. It is designed to deploy and maintain core infrastructure, platform services, monitoring, logging, and applications. This cluster hosts various services, including authentication, storage, and data sources.

## Dependency Chain
The cluster's Kustomizations are applied in a specific order to ensure proper dependency resolution:

1. **infrastructure-core**: Deploys essential infrastructure components such as Multus, Cert-Manager, and Victoria Metrics Operator.
2. **infrastructure-platform**: Builds on the core infrastructure to provide platform-level services.
3. **infrastructure-monitoring**: Adds monitoring capabilities, including the deployment of `vmagent-livingroom-pi`.
4. **infrastructure-logging**: Configures logging services, including the `vector-agent` DaemonSet.
5. **apps**: Deploys applications such as `authentik`, `etcd`, `seaweedfs`, and `sources`. This depends on the platform infrastructure and is the final step in the chain.

## Components
### Infrastructure
- **infrastructure-core**  
  Path: `./infrastructure/core/livingroom-pi`  
  Health Checks:  
  - Multus (`flux-system` namespace)  
  - Cert-Manager (`cert-manager` namespace)  
  - Victoria Metrics Operator (`victoria-metrics` namespace)  

- **infrastructure-platform**  
  Path: `./infrastructure/platform/livingroom-pi`  

- **infrastructure-monitoring**  
  Path: `./infrastructure/monitoring/livingroom-pi`  
  Health Checks:  
  - vmagent-livingroom-pi (`monitoring` namespace)  

- **infrastructure-logging**  
  Path: `./infrastructure/logging/livingroom-pi`  
  Health Checks:  
  - Vector Agent (`logging` namespace)  

### Applications
- **apps**  
  Path: `./apps/livingroom-pi`  
  Deployed Applications:  
  - `authentik`  
  - `etcd`  
  - `seaweedfs`  
  - `sources`  

## Variable Injection
The following Secrets are used for postBuild substitution across Kustomizations:

- **cluster-infrastructure-vars** (mandatory)  
- **cluster-vars** (optional)  
- **cluster-app-vars** (optional, used only in `apps` Kustomization`)  

These Secrets provide dynamic values to customize the deployment configurations.
