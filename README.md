<div align="center">

<img src="https://avatars.githubusercontent.com/u/61287648?s=200&v=4" align="center" width="144px" height="144px" alt="kubernetes"/>

## Home Kubernetes cluster

</div>

<br/>

<div align="center">

[![Talos](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flarivierec%2Fhome-cluster%2Fmain%2Fbootstrap%2Ftalos%2Ftalconfig.yaml&query=talosVersion&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flarivierec%2Fhome-cluster%2Fmain%2Fbootstrap%2Ftalos%2Ftalconfig.yaml&query=kubernetesVersion&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;

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

# Kubernetes with Talos

# Networking

### Notes

#### Cilium CNI

Be sure to set the Pod CIDR to the one you have chosen if you aren't using the Talos default. `10.42.0.0/16`
Otherwise, you will more than likely have issues.

#### Gateway API

Ingress and Gateway API can co-exist.
Keep in mind, the DNS must simply be unique.

You'll notice in my repo most of my external/internal services have both route and ingress.
I've noticed after using Gateway-API extensively with Cilium that it is not stable enough, and therefore, opted to use envoy's implementation.

So far, it's probably one of the best Gateway API implementation that i've used.

#### Ingress

For ingress controller we need to add this in order to get proper ip address from Cloudflare LB @ L7.

```yaml
data:
  use-forwarded-headers: "true"
  forwarded-for-header: "CF-Connecting-IP"
```

SOPS is only used to create the helm-release required for bitwarden and external-secrets.
Previously, it was used throughout the repository however, with external-secrets, bitwarden-sdk, we're able to remove this dependency slightly.

External-Secrets uses bitwarden container to retrieve my bitwarden secrets and creates kubernetes secrets with them.

Also keep in mind, that since the bitwarden container exposes your bitwarden vault, it's good practice to limit who can communicate with it. See the network policy at `kubernetes/main/apps/kube-system/external-secrets/app/network-policy.yaml`

# Nodes/Hardware

| Device                    | Count | OS Disk Size            | Data Disk Size              | Ram  | Operating System | Purpose              |
| --------------------------|-------|-------------------------|-----------------------------|------|------------------|--------------------- |
| Synology RS1221+          | 1     | 36Ti  HDD / 2Ti NVMe    | -                           | 4Gi  | DSM 7            | NAS                  |
| UDM Pro Max               | 1     |                         | -                           |  -   | Unifi OS - 4.1   | Router / Gateway     |
| Unifi Core Switch XG-16   | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Unifi Enterprise 24 PoE   | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Unifi Flex 2.5G PoE       | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Unifi Flex 2.5G Mini      | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Beelink U59 N5105         | 3     | 500Gi M2 SATA           | -                           | 16Gi | Talos            | Kubernetes Masters   |
| MS-01                     | 3     | 250Gi NVMe              | 1Ti U.2 NVMe                | 64Gi | Talos            | Kubernetes Workers   |
---

#### Extra Documentation

1. [frigate](kubernetes/apps/home/frigate/README.md)
2. [scrypted](kubernetes/apps/home/scrypted/README.md)

#### Archived Documentation

1. [tailscale-operator](.archive/apps/networking/tailscale-gateway/operator/README.md)
2. [nvidia-device-plugin](.archive/apps/kube-system/nvidia/device-plugin/README.md)

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
