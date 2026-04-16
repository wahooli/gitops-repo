---
title: "Home"
nav_order: 0
---

# GitOps Repository Documentation

This repository manages multiple Kubernetes clusters using Flux CD, Cilium, Kustomize, and Helm. It provides a structured approach to deploying and managing applications and infrastructure components across different environments.

### livingroom-pi
- [Cluster overview](livingroom-pi/overview.md)

**Apps:**
- [authentik](livingroom-pi/apps/authentik.md)
- [etcd](livingroom-pi/apps/etcd.md)
- [sources](livingroom-pi/apps/sources.md)

**Infrastructure / core:**
- [cert-manager](livingroom-pi/infrastructure/core/cert-manager.md)
- [gateway-api](livingroom-pi/infrastructure/core/gateway-api.md)
- [multus](livingroom-pi/infrastructure/core/multus.md)
- [namespaces](livingroom-pi/infrastructure/core/namespaces.md)
- [prometheus-operator-crds](livingroom-pi/infrastructure/core/prometheus-operator-crds.md)
- [sources](livingroom-pi/infrastructure/core/sources.md)
- [victoria-metrics](livingroom-pi/infrastructure/core/victoria-metrics.md)

**Infrastructure / logging:**
- [vector-agent](livingroom-pi/infrastructure/logging/vector-agent.md)

**Infrastructure / monitoring:**
- [monitoring](livingroom-pi/infrastructure/monitoring/monitoring.md)

**Infrastructure / platform:**
- [cert-manager-issuers](livingroom-pi/infrastructure/platform/cert-manager-issuers.md)
- [kube-state-metrics](livingroom-pi/infrastructure/platform/kube-state-metrics.md)
- [multus-networks](livingroom-pi/infrastructure/platform/multus-networks.md)
- [node-exporter](livingroom-pi/infrastructure/platform/node-exporter.md)
- [node-local-dns](livingroom-pi/infrastructure/platform/node-local-dns.md)
- [reflector](livingroom-pi/infrastructure/platform/reflector.md)
- [reloader](livingroom-pi/infrastructure/platform/reloader.md)
- [resources](livingroom-pi/infrastructure/platform/resources.md)
- [velero](livingroom-pi/infrastructure/platform/velero.md)

### nas
- [Cluster overview](nas/overview.md)

**Apps:**
- [authentik](nas/apps/authentik.md)
- [bazarr](nas/apps/bazarr.md)
- [crowdsec](nas/apps/crowdsec.md)
- [deluge](nas/apps/deluge.md)
- [etcd](nas/apps/etcd.md)
- [forgejo](nas/apps/forgejo.md)
- [grafana](nas/apps/grafana.md)
- [jellyfin](nas/apps/jellyfin.md)
- [jellyplex-watched](nas/apps/jellyplex-watched.md)
- [plex](nas/apps/plex.md)
- [prowlarr](nas/apps/prowlarr.md)
- [ps3netsrv](nas/apps/ps3netsrv.md)
- [radarr](nas/apps/radarr.md)
- [seaweedfs](nas/apps/seaweedfs.md)
- [sonarr](nas/apps/sonarr.md)
- [transmission-old](nas/apps/transmission-old.md)
- [transmission](nas/apps/transmission.md)

**Infrastructure / alerting:**
- [alerting](nas/infrastructure/alerting/alerting.md)

**Infrastructure / core:**
- [cert-manager](nas/infrastructure/core/cert-manager.md)
- [cilium](nas/infrastructure/core/cilium.md)
- [envoy-gateway](nas/infrastructure/core/envoy-gateway.md)
- [gateway-api](nas/infrastructure/core/gateway-api.md)
- [keda](nas/infrastructure/core/keda.md)
- [namespaces](nas/infrastructure/core/namespaces.md)
- [prometheus-operator-crds](nas/infrastructure/core/prometheus-operator-crds.md)
- [reflector](nas/infrastructure/core/reflector.md)
- [sources](nas/infrastructure/core/sources.md)
- [topolvm](nas/infrastructure/core/topolvm.md)
- [victoria-metrics](nas/infrastructure/core/victoria-metrics.md)

**Infrastructure / internal-dns:**
- [bind9](nas/infrastructure/internal-dns/bind9.md)
- [blocky](nas/infrastructure/internal-dns/blocky.md)
- [client-lookup](nas/infrastructure/internal-dns/client-lookup.md)
- [nas-external-dns](nas/infrastructure/internal-dns/nas-external-dns.md)
- [resources](nas/infrastructure/internal-dns/resources.md)
- [tpi-1-external-dns](nas/infrastructure/internal-dns/tpi-1-external-dns.md)
- [unbound](nas/infrastructure/internal-dns/unbound.md)

**Infrastructure / kube-dns:**
- [kube-dns](nas/infrastructure/kube-dns/kube-dns.md)

**Infrastructure / logging:**
- [resources](nas/infrastructure/logging/resources.md)
- [vector-agent](nas/infrastructure/logging/vector-agent.md)
- [vector-global-write](nas/infrastructure/logging/vector-global-write.md)
- [vector-lb](nas/infrastructure/logging/vector-lb.md)

**Infrastructure / monitoring:**
- [monitoring](nas/infrastructure/monitoring/monitoring.md)

**Infrastructure / platform:**
- [cert-manager-issuers](nas/infrastructure/platform/cert-manager-issuers.md)
- [cilium](nas/infrastructure/platform/cilium.md)
- [default-backend](nas/infrastructure/platform/default-backend.md)
- [envoy-gateway](nas/infrastructure/platform/envoy-gateway.md)
- [forgejo-runner](nas/infrastructure/platform/forgejo-runner.md)
- [gateway](nas/infrastructure/platform/gateway.md)
- [gpu-exporter](nas/infrastructure/platform/gpu-exporter.md)
- [haproxy](nas/infrastructure/platform/haproxy.md)
- [ingress-nginx](nas/infrastructure/platform/ingress-nginx.md)
- [kube-state-metrics](nas/infrastructure/platform/kube-state-metrics.md)
- [node-exporter](nas/infrastructure/platform/node-exporter.md)
- [reflector](nas/infrastructure/platform/reflector.md)
- [reloader](nas/infrastructure/platform/reloader.md)
- [resources](nas/infrastructure/platform/resources.md)
- [seaweedfs-backup](nas/infrastructure/platform/seaweedfs-backup.md)
- [seaweedfs](nas/infrastructure/platform/seaweedfs.md)
- [smartctl-exporter](nas/infrastructure/platform/smartctl-exporter.md)
- [velero](nas/infrastructure/platform/velero.md)
- [zot](nas/infrastructure/platform/zot.md)

### tpi-1
- [Cluster overview](tpi-1/overview.md)

**Apps:**
- [authentik](tpi-1/apps/authentik.md)
- [crowdsec](tpi-1/apps/crowdsec.md)
- [etcd](tpi-1/apps/etcd.md)
- [forgejo](tpi-1/apps/forgejo.md)
- [grafana](tpi-1/apps/grafana.md)
- [mail-relay](tpi-1/apps/mail-relay.md)
- [ombi](tpi-1/apps/ombi.md)
- [overseerr](tpi-1/apps/overseerr.md)
- [paperless-ngx](tpi-1/apps/paperless-ngx.md)
- [sources](tpi-1/apps/sources.md)
- [tautulli](tpi-1/apps/tautulli.md)
- [vaultwarden](tpi-1/apps/vaultwarden.md)

**Infrastructure / alerting:**
- [alerting](tpi-1/infrastructure/alerting/alerting.md)

**Infrastructure / core:**
- [cert-manager](tpi-1/infrastructure/core/cert-manager.md)
- [cilium](tpi-1/infrastructure/core/cilium.md)
- [envoy-gateway](tpi-1/infrastructure/core/envoy-gateway.md)
- [gateway-api](tpi-1/infrastructure/core/gateway-api.md)
- [namespaces](tpi-1/infrastructure/core/namespaces.md)
- [prometheus-operator-crds](tpi-1/infrastructure/core/prometheus-operator-crds.md)
- [sources](tpi-1/infrastructure/core/sources.md)
- [topolvm](tpi-1/infrastructure/core/topolvm.md)
- [victoria-metrics](tpi-1/infrastructure/core/victoria-metrics.md)

**Infrastructure / internal-dns:**
- [bind9](tpi-1/infrastructure/internal-dns/bind9.md)
- [blocky](tpi-1/infrastructure/internal-dns/blocky.md)
- [client-lookup](tpi-1/infrastructure/internal-dns/client-lookup.md)
- [nas-external-dns](tpi-1/infrastructure/internal-dns/nas-external-dns.md)
- [resources](tpi-1/infrastructure/internal-dns/resources.md)
- [tpi-1-external-dns](tpi-1/infrastructure/internal-dns/tpi-1-external-dns.md)
- [unbound](tpi-1/infrastructure/internal-dns/unbound.md)

**Infrastructure / kube-dns:**
- [kube-dns](tpi-1/infrastructure/kube-dns/kube-dns.md)

**Infrastructure / logging:**
- [resources](tpi-1/infrastructure/logging/resources.md)
- [vector-agent](tpi-1/infrastructure/logging/vector-agent.md)
- [vector-global-write](tpi-1/infrastructure/logging/vector-global-write.md)
- [vector-lb](tpi-1/infrastructure/logging/vector-lb.md)
- [vlogs-short-term](tpi-1/infrastructure/logging/vlogs-short-term.md)

**Infrastructure / monitoring:**
- [resources](tpi-1/infrastructure/monitoring/resources.md)
- [vm-short-term-server-cluster](tpi-1/infrastructure/monitoring/vm-short-term-server-cluster.md)

**Infrastructure / platform:**
- [cert-manager-issuers](tpi-1/infrastructure/platform/cert-manager-issuers.md)
- [cilium](tpi-1/infrastructure/platform/cilium.md)
- [default-backend](tpi-1/infrastructure/platform/default-backend.md)
- [envoy-gateway](tpi-1/infrastructure/platform/envoy-gateway.md)
- [gateway](tpi-1/infrastructure/platform/gateway.md)
- [haproxy](tpi-1/infrastructure/platform/haproxy.md)
- [ingress-nginx](tpi-1/infrastructure/platform/ingress-nginx.md)
- [kube-state-metrics](tpi-1/infrastructure/platform/kube-state-metrics.md)
- [node-exporter](tpi-1/infrastructure/platform/node-exporter.md)
- [reflector](tpi-1/infrastructure/platform/reflector.md)
- [reloader](tpi-1/infrastructure/platform/reloader.md)
- [resources](tpi-1/infrastructure/platform/resources.md)
- [seaweedfs](tpi-1/infrastructure/platform/seaweedfs.md)
- [velero](tpi-1/infrastructure/platform/velero.md)
- [zot](tpi-1/infrastructure/platform/zot.md)
