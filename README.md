<div align="center">

<img src="https://avatars.githubusercontent.com/u/61287648?s=200&v=4" align="center" width="144px" height="144px" alt="kubernetes"/>

## Home Kubernetes cluster

</div>

<br/>

<div align="center">

[![Talos](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flarivierec%2Fhome-cluster%2Fmain%2Fkubernetes%2Fmain%2Fbootstrap%2Ftalos%2Ftalconfig.yaml&query=talosVersion&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flarivierec%2Fhome-cluster%2Fmain%2Fkubernetes%2Fmain%2Fbootstrap%2Ftalos%2Ftalconfig.yaml&query=kubernetesVersion&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;

[![Discord](https://img.shields.io/discord/673534664354430999?color=7289da&label=DISCORD&style=for-the-badge)](https://discord.gg/home-operations)&nbsp;&nbsp;
[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?style=for-the-badge&logo=renovatebot&logoColor=white)](https://github.com/renovatebot/renovate)

</div>

---

# Kubernetes with Talos

# Networking

## OPNsense

Note: Add an entry to the BGP Neighbors table with the IP address of the Node you're adding.

I use Tailscale on the router and another one inside the cluster.
Both of them broadcasts my network and act as exit nodes for Tailscale clients.

- Apple TV exit node
- Cluster exit node

Having both isn't necessary because if you lose internet you won't be able to access either remotely.
The difference is if i'm playing around with stuff inside the cluster and the cluster breaks, I may no longer be able to use the exit node in the cluster; The exit node inside the cluster is the main exit node.

Having the ability to not put unnecessary strain on the router is the reason why i'm running 2 exit nodes + 2 subnet broadcasts.
If I have internet access and the cluster explodes for whatever reason, at least, i'll still be able to access my network remotely.

### Notes

#### Cilium CNI

Be sure to set the Pod CIDR to the one you have chosen if you aren't using the Talos default. `10.42.0.0/16`
Otherwise, you will more than likely have issues.

The APIServer address must also be correct otherwise, the cni will not be installed on the nodes.
I have the three master node IP addresses registered to the HAProxy on my router on port 6443.

#### Unifi

As I have unifi hardware, you cannot wait for the Unifi Software controller.
You have 2 options.

1. Get a cloud key / security gateway
2. Self-host on something reliable like a NAS.

I opted for option 2 because it's cheaper and does almost the same, except you manage your own backups and etc.
When I just had APs this didn't bother me, however, now with Switches your NAS must be up and running before setting up the switch.

Maybe this could've been run on a router but I did not want to introduce more stress

#### Gateway API

Ingress and Gateway API can co-exist.
Keep in mind, the DNS must simply be unique.

You'll notice in my repo most of my external/internal services have both route and ingress.
I've noticed after using Gateway-API extensively with Cilium, that it is not stable enough.
For this reason, I have kept both and when Cilium's implementation decides to stop functioning, I have ingress available.

#### Ingress

For ingress controller we need to add this in order to get proper ip address from Cloudflare LB @ L7.

```yaml
data:
  use-forwarded-headers: "true"
  forwarded-for-header: "CF-Connecting-IP"
```

## Flux

### Installation

1. `Generate a personal access token (PAT) that can create repositories by checking all permissions under repo. If a pre-existing repository is to be used the PAT’s user will require admin permissions on the repository in order to create a deploy key.` [Flux Installation](https://fluxcd.io/docs/installation)

```bash
export GITHUB_USER=<user>
export GITHUB_TOKEN=<token>

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=home-cluster \
  --branch=main \
  --path=./kubernetes/main/bootstrap \
  --personal
```

2. Install the sops secret either age [sops age](https://fluxcd.io/docs/guides/mozilla-sops/#encrypting-secrets-using-age)

```bash
age-keygen -o age.agekey

cat age.agekey |
kubectl create secret generic sops-age \
--namespace=flux-system \
--from-file=age.agekey=/dev/stdin
```

3. Add these secrets

```bash
flux create secret ghcr-auth \
  --url=ghcr.io \
  --username=flux \
  --password=${GITHUB_PAT}

flux create secret oci dockerio-auth \
  --url=registry-1.docker.io \
  --username=<username> \
  --password=<password>
```

SOPS is only used to create the helm-release required for bitwarden and external-secrets.
Previously, it was used throughout the repository however, with external-secrets, bitwarden-sdk, we're able to remove this dependency slightly.

External-Secrets uses bitwarden container to retrieve my bitwarden secrets and creates kubernetes secrets with them.

Also keep in mind, that since the bitwarden container exposes your bitwarden vault, it's good practice to limit who can communicate with it. See the network policy at `kubernetes/main/apps/kube-system/external-secrets/app/network-policy.yaml`

3. Ensure you use this `sops-age` secret for decrypting.

# Nodes/Hardware

| Device                    | Count | OS Disk Size            | Data Disk Size              | Ram  | Operating System | Purpose              |
| --------------------------|-------|-------------------------|-----------------------------|------|------------------|--------------------- |
| J4125 RS34g               | 1     | 250Gi mSATA             | -                           | 16Gi | OPNsense 24      | Router               |
| Synology RS1221+          | 1     | 36Ti  HDD / 2Ti NVMe    | -                           | 4Gi  | DSM 7            | NAS                  |
| Unifi Core Switch XG-16   | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Unifi Enterprise 24 PoE   | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Beelink U59 N5105         | 3     | 500Gi M2 SATA           | -                           | 16Gi | Ubuntu 22.04     | Kubernetes Masters   |
| MS-01                     | 3     | 250Gi NVMe              | 1Ti U.2 NVMe                | 64Gi | Debian 12        | Kubernetes Workers   |
| NVIDIA - GPU PC           | 1     | 250Gi NVMe              | 2Ti NVMe                    | 32Gi | Ubuntu 22.04     | Kubernetes Worker    |
---

#### Extra Documentation

1. [frigate](kubernetes/apps/home/frigate/README.md)
2. [scrypted](kubernetes/apps/home/scrypted/README.md)
3. [nvidia-device-plugin](kubernetes/apps/kube-system/nvidia/device-plugin/README.md)
4. [tailscale-operator](.archive/apps/networking/tailscale-gateway/operator/README.md)

## ⭐ Stargazers

[![Star History Chart](https://api.star-history.com/svg?repos=larivierec/home-cluster&type=Date)](https://star-history.com/#larivierec/home-cluster&Date)

## 🤝 Gratitude and Thanks

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) Discord community. Be sure to check out [kubesearch.dev](https://kubesearch.dev/) for ideas on how to deploy applications or get ideas on what you may deploy.

- onedr0p
- bernd-schorgers / bjw-s
- buroa
- joryirving

For all their hard work and dedication
