---
title: "sonarr"
parent: "Apps"
grand_parent: "nas"
---

# sonarr

## Overview
Sonarr is a TV series management tool that automates the downloading, sorting, and renaming of TV shows. It integrates with various download clients and provides a web interface for managing your media library. In this deployment, Sonarr is configured to run in the `default` namespace of the Kubernetes cluster named `nas`.

## Sub-components
This deployment consists of a single HelmRelease:
- **HelmRelease**: `default--sonarr`
  - **Chart**: sonarr
  - **Version**: latest (floating: >=0.1.1-0)
  - **Target Namespace**: default
  - **Provides**: Deployment, Service, PersistentVolumeClaim, and ServiceAccount for managing the Sonarr application.

## Dependencies
There are no explicit dependencies defined for this HelmRelease.

## Helm Chart(s)
- **Chart Name**: sonarr
- **Repository**: wahooli (oci://ghcr.io/wahooli/charts)
- **Version**: latest (floating: >=0.1.1-0)

## Resource Glossary
### Networking
- **HTTPRoute**: Defines routes for HTTP traffic to the Sonarr application, allowing access via specified hostnames and paths.
- **Service**: Exposes the Sonarr application internally within the cluster on port 8989 for HTTP traffic and port 9707 for metrics.

### Storage
- **PersistentVolumeClaim**: Requests a persistent volume for storing Sonarr's configuration data, ensuring that data is retained across pod restarts.

### Security
- **ServiceAccount**: Provides an identity for the Sonarr application to interact with the Kubernetes API, allowing it to manage resources as needed.

### Application Workload
- **Deployment**: Manages the Sonarr application pods, ensuring that the desired number of replicas are running and handling updates and rollbacks.

## Configuration Highlights
- **Resource Requests/Limits**: The Sonarr application is configured with CPU limits of 200m and memory limits of 60Mi.
- **Persistence**: Config and data persistence are enabled, with a 2Gi storage request for the config and a host path for data storage.
- **Environment Variables**: Key environment variables include `PGID`, `PUID`, and `TZ` for user and timezone configuration, as well as metrics-related settings for the Sonarr exporter.

## Deployment
- **Target Namespace**: default
- **Release Name**: sonarr
- **Reconciliation Interval**: 5m
- **Install/Upgrade Behavior**: The HelmRelease is set to retry indefinitely on failure during installation or upgrades.
