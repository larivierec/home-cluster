<div align="center">

<img src="https://avatars.githubusercontent.com/u/61287648?s=200&v=4" align="center" width="144px" height="144px" alt="kubernetes"/>

## Home Kubernetes cluster

</div>

<br/>

<div align="center">

[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.garb.dev%2Ftalos_version&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.garb.dev%2Fkubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;

[![Discord](https://img.shields.io/discord/673534664354430999?color=7289da&label=DISCORD&style=for-the-badge)](https://discord.gg/home-operations)&nbsp;&nbsp;
[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?style=for-the-badge&logo=renovatebot&logoColor=white)](https://github.com/renovatebot/renovate)

</div>

<div align="center">

[![Age-Days](https://kromgo.garb.dev/cluster_age_days?format=badge&style=flat-square)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![Uptime-Days](https://kromgo.garb.dev/cluster_uptime_days?format=badge&style=flat-square)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![Node-Count](https://kromgo.garb.dev/cluster_node_count?format=badge&style=flat-square)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![Pod-Count](https://kromgo.garb.dev/cluster_pod_count?format=badge&style=flat-square)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![CPU-Usage](https://kromgo.garb.dev/cluster_cpu_usage?format=badge&style=flat-square)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![Memory-Usage](https://kromgo.garb.dev/cluster_memory_usage?format=badge&style=flat-square)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![Power-Usage](https://kromgo.garb.dev/cluster_power_usage?format=badge&style=flat-square)](https://github.com/kashalls/kromgo/)

</div>

---

# Overview

A monorepo that collects the pieces needed to run my homelab Kubernetes cluster and services. It contains infrastructure, cluster manifests, helper scripts and small service projects. The repo is organized to keep infra, apps and bootstrap tooling together so a single place holds the canonical manifests and generation scripts.

## High level

- Monorepo: infra, Kubernetes manifests, bootstrap helpers and service code live together.
- Goal: reproducible, git-driven cluster configuration (Flux + sops) with a small Bootstrap helper to generate local TLS material and secrets.
- Primary features used: Cilium for networking, Gateway API driven by Envoy (envoy-gateway) for ingress & edge, and 1Password as the external secrets provider.

## Kubernetes

### Core components

- Kubernetes manifests
	- Path: `kubernetes/main/...` — apps and components are organized per-namespace and per-app.
	- Flux and GitOps friendly YAML layout (Flux will pick manifests from the cluster repo).

- Networking: Cilium
	- Cluster CNI: Cilium handles L3/L4 networking, policy and load-balancing.

- Ingress / edge: Gateway API + Envoy (envoy-gateway)
	- Gateway resources live under `kubernetes/main/apps/networking/gateway/envoy/manifests`.
	- Uses Gateway API (Gateway, HTTPRoute, Backend, BackendTLSPolicy, BackendTrafficPolicy, ClientTrafficPolicy) to explicitly configure client TLS and upstream TLS.

- Secrets & Secrets provider
	- ExternalSecrets configuration lives under `kubernetes/main/apps/kube-system/external-secrets/...`.
	- A ClusterSecretStore is configured to use 1Password Connect as the secrets provider.

### External Secrets flow

- The external-secrets operator pulls secrets from 1Password Connect.
- The ClusterSecretStore config points at the 1Password Connect server:
	- File: `kubernetes/main/apps/kube-system/external-secrets/stores/secret-store.yaml`
	- Note: 1Password Connect credentials are stored as Kubernetes secrets and referenced by the ClusterSecretStore.

### TLS, certificates and common pitfalls

- Two separate TLS problems commonly show up:
	1. Client TLS (client → Gateway): configure the Gateway listener with `certificateRefs` pointing at a TLS secret in the Gateway's namespace (e.g., `networking`).
	2. Upstream TLS (Gateway/Envoy → backend): configure `Backend` and `BackendTLSPolicy` to instruct Envoy how to speak TLS to upstream services: trust/CA, SNI/hostname, min/max TLS versions. Secrets referenced for upstream trust must be accessible to the Gateway/controller namespace.

### Where to look (quick map)
- Bootstrap
	- `bootstrap/bootstrap.sh` (creates Flux secrets including age key and GitHub credentials)

- Gateway (Envoy)
	- `kubernetes/main/apps/networking/gateway/envoy/manifests/gateway.yaml`
	- `kubernetes/main/apps/networking/gateway/envoy/manifests/backend-policy.yaml`

- ExternalSecrets store
	- `kubernetes/main/apps/kube-system/external-secrets/stores/secret-store.yaml`

### Quick commands
- Bootstrap Flux secrets:
```bash
bash bootstrap/bootstrap.sh
```

# Nodes/Hardware

| Device                    | Count | OS Disk Size            | Data Disk Size              | Ram  | Operating System | Purpose              |
| --------------------------|-------|-------------------------|-----------------------------|------|------------------|--------------------- |
| MS-01                     | 3     | 250Gi NVMe              | 1Ti U.2 NVMe                | 64Gi | Talos            | Kubernetes           |
| Synology RS1221+          | 1     | 36Ti  HDD / 2Ti NVMe    | -                           | 4Gi  | DSM 7            | NAS                  |
| UDM Pro Max               | 1     |                         | -                           |  -   |                  | Router / Gateway     |
| Unifi Core Switch XG-16   | 1     |            -            | -                           |  -   |                  | Switch               |
| Unifi Enterprise 24 PoE   | 1     |            -            | -                           |  -   |                  | Switch               |
| Unifi Flex 2.5G PoE       | 1     |            -            | -                           |  -   |                  | Switch               |
| Unifi Flex 2.5G Mini      | 1     |            -            | -                           |  -   |                  | Switch               |
| Unifi PDU Pro             | 1     |            -            | -                           |  -   |                  | Power Delivery       |

---

#### Extra Documentation

1. [frigate](kubernetes/main/apps/home/frigate/README.md)
2. [scrypted](kubernetes/main/apps/home/scrypted/README.md)

## ⭐ Stargazers

[![Star History Chart](https://api.star-history.com/svg?repos=larivierec/home-cluster&type=Date)](https://www.star-history.com/#larivierec/home-cluster&Date)

## 🤝 Gratitude and Thanks

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) Discord community. Be sure to check out [kubesearch.dev](https://kubesearch.dev/) for ideas on how to deploy applications or get ideas on what you may deploy.

- onedr0p
- bernd-schorgers / bjw-s
- buroa
- joryirving
- [home-operations](https://github.com/home-operations) 

For all their hard work and dedication
