---
title: "node-exporter"
parent: "Infrastructure / Platform"
grand_parent: "nas"
---

# Node Exporter

## Overview
The Node Exporter component provides system-level metrics for Kubernetes nodes, enabling monitoring of hardware and operating system metrics such as CPU usage, memory, disk I/O, and network statistics. It is deployed as a DaemonSet, ensuring that an instance runs on every node in the cluster. This component is essential for collecting metrics used by Prometheus and other monitoring tools.

## Dependencies
The Node Exporter HelmRelease depends on `prometheus-operator--prometheus-operator-crds`, which provides the necessary Custom Resource Definitions (CRDs) for Prometheus Operator. These CRDs enable integration with Prometheus for scraping metrics from Node Exporter.

## Helm Chart(s)
- **Chart Name**: prometheus-node-exporter  
- **Repository**: prometheus-community (https://prometheus-community.github.io/helm-charts)  
- **Version**: 4.52.0  

## Resource Glossary
### Networking
- **Service**:  
  - Name: `node-exporter`  
  - Type: `ClusterIP`  
  - Port: `9100`  
  - Purpose: Exposes the metrics endpoint for Prometheus to scrape.  

### Security
- **ServiceAccount**:  
  - Name: `node-exporter`  
  - Automount Service Account Token: Disabled for enhanced security.  

### Workload
- **DaemonSet**:  
  - Name: `node-exporter`  
  - Ensures that Node Exporter runs on every node in the cluster.  
  - Security Context:  
    - Runs as a non-root user (`65534`).  
    - Read-only root filesystem for container security.  
  - Host Network: Enabled to bind directly to the node's network interface.  
  - Node Affinity: Ensures deployment only on Linux nodes and excludes virtual-kubelet and Fargate nodes.  
  - Tolerations: Allows scheduling on nodes with `NoSchedule` taints.  
  - Volumes:  
    - `/proc`, `/sys`, and `/` mounted from the host for accessing system-level metrics.  

## Configuration Highlights
- **Extra Arguments**:  
  - Excludes specific filesystem mount points and network devices from metrics collection to avoid unnecessary data.  
  - Disables collectors for XFS, tapestats, bonding, bcache, and other unused subsystems.  
  - Configures logging format as JSON for structured logging.  
- **Environment Variables**:  
  - `HOST_IP`: Set to `0.0.0.0` to bind the metrics endpoint to all interfaces.  
- **Probes**:  
  - Liveness and readiness probes are configured to ensure the container is healthy and ready to serve metrics.  

## Deployment
- **Target Namespace**: `kube-system`  
- **Release Name**: `node-exporter`  
- **Reconciliation Interval**: 10 minutes  
- **Install/Upgrade Behavior**:  
  - Unlimited retries for remediation in case of installation or upgrade failures.  

This component is configured to provide reliable and secure metrics collection for all nodes in the cluster, with integration into Prometheus for monitoring and alerting.
