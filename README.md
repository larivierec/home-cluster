<div align="center">

<img src="https://avatars.githubusercontent.com/u/61287648?s=200&v=4" align="center" width="144px" height="144px" alt="kubernetes"/>

## Home Kubernetes cluster

</div>

<br/>

<div align="center">

[![Discord](https://img.shields.io/discord/673534664354430999?color=7289da&label=DISCORD&style=for-the-badge)](https://discord.gg/sTMX7Vh)
[![k3s](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flarivierec%2Fhome-cluster%2Fmain%2Fkubernetes%2Fapps%2Fsystem-upgrade%2Fsystem-upgrade-controller%2Fplans%2Fserver.yaml&query=spec.version&logo=k3s&label=k3s&style=for-the-badge)](https://k3s.io)
[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?style=for-the-badge&logo=renovatebot&logoColor=white)](https://github.com/renovatebot/renovate)

</div>

---

# Kubernetes with k3s

## Setup

k3s cluster will also be configured as an HA using etcd with the `--cluster-init` flag

## Config File

### Server

1. Install k3s manually

```bash
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server" sh -s - --flannel-backend none \
        --disable traefik \
        --disable servicelb \
        --disable coredns \
        --disable-network-policy \
        --disable-kube-proxy \
        --kube-controller-manager-arg bind-address=0.0.0.0 \
        --kube-scheduler-arg bind-address=0.0.0.0 \
        --etcd-expose-metrics \
        --cluster-init
```

2. Add extra masters if need be.

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server --server https://<hostname or ip>:6443 --flannel-backend none \
        --disable traefik \
        --disable servicelb \
        --disable coredns \
        --disable-network-policy \
        --disable-kube-proxy \
        --kube-controller-manager-arg bind-address=0.0.0.0 \
        --kube-scheduler-arg bind-address=0.0.0.0 \
        --etcd-expose-metrics
```

3. Add workers

### Workers

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN="" K3S_URL=https://<ip:port> sh -
```

### Initialize

#### Coredns

4. use bootstrap values from kubernetes/apps/kube-system

```bash
helm repo add coredns https://coredns.github.io/helm
helm install coredns coredns/coredns -f coredns/bootstrap/values.yaml --namespace kube-system
```

#### Cilium

```bash
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium -f cilium/bootstrap/values.yaml --namespace kube-system
```
---

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

Be sure to set the Pod CIDR to the one you have chosen if you aren't using the k3s default. `10.42.0.0/16`
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
  --path=./kubernetes/bootstrap \
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
Previously, it was used throughout the repository however, with external-secrets bitwarden and webhooks, we're able to remove this dependency slightly.

External-Secrets uses bitwarden-cli container to retrieve my vault items and creates kubernetes secrets with them. Since `external-secrets` doesn't use the bitwarden API directly, we have to use a container with the cli and webhooks.

Also keep in mind, that since the bitwarden container exposes your bitwarden vault, it's good practice to limit who can communicate with it. See the network policy at `kubernetes/core/bitwarden/network-policy.yaml`

3. Ensure you use this `sops-age` secret for decrypting.

# Nodes/Hardware

| Device                    | Count | OS Disk Size            | Data Disk Size              | Ram  | Operating System | Purpose              |
| --------------------------|-------|-------------------------|-----------------------------|------|------------------|--------------------- |
| J4125 RS34g               | 1     | 250Gi mSATA             | -                           | 16Gi | OPNsense 24      | Router               |
| Synology RS1221+          | 1     | 36Ti  HDD / 2Ti NVMe    | -                           | 4Gi  | DSM 7            | NAS                  |
| Unifi Core Switch XG-16   | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Unifi Enterprise 24 PoE   | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Beelink U59 N5105         | 3     | 500Gi M2 SATA           | -                           | 16Gi | Ubuntu 22.04     | Kubernetes Masters   |
| MS-01                     | 2     | 250Gi NVMe              | 1Ti U.2 NVMe                | 64Gi | Debian 12        | Kubernetes Workers   |
| NVIDIA - GPU PC           | 1     | 250Gi NVMe              | 2Ti NVMe                    | 32Gi | Ubuntu 22.04     | Kubernetes Worker    |
---

# Base Node Install

## Nodes

### Base install

#### Ubuntu

```bash
sudo apt install \
  nftables \
  nfs-common \
  curl \
  containerd \
  open-iscsi \
  vim \
  gnupg \
  net-tools \
  dnsutils
```

### Bonding

```text
root@dlp:~# ls /etc/netplan

00-installer-config.yaml.org 01-netcfg.yaml
# edit network settings

root@dlp:~# vi /etc/netplan/01-netcfg.yaml

# change all like follows
# replace the interface name, IP address, DNS, Gateway to your environment value
# for [mode] section, set a mode you'd like to use
network:
  ethernets:
    enp1s0:
      dhcp4: false
      dhcp6: false
    enp7s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond0:
      addresses: [10.0.0.30/24]
      routes:
        - to: default
          via: 10.0.0.1
          metric: 100
      interfaces:
        - enp1s0
        - enp7s0
      parameters:
        mode: 802.3ad
        mii-monitor-interval: 100
  version: 2

# apply changes

root@dlp:~# netplan apply
# after setting bonding, [bonding] is loaded automatically

root@dlp:~# lsmod | grep bond

bonding               196608  0
tls                   114688  1 bonding
```
[Reference](https://www.server-world.info/en/note?os=Ubuntu_22.04&p=bonding)

#### Debian

Note: Disable Secure Boot, otherwise PCIe Coral driver won't install.

```bash
sudo apt install \
  nftables \
  iptables \
  nfs-common \
  curl \
  containerd \
  open-iscsi \
  vim \
  gnupg \
  net-tools \
  dnsutils \
  ifenslave \ # bonds
  ethtool \
  systemd-timesyncd
```

### Bonding

```text
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp89s0
# for auto up
allow-hotplug enp89s0
iface enp89s0 inet dhcp

auto enp87s0
allow-hotplug enp87s0
iface enp87s0 inet dhcp

auto enp2s0f0
iface enp2s0f0 inet manual
  bond-master bond0
  bond-mode 802.3ad
auto enp2s0f1
iface enp2s0f1 inet manual
  bond-master bond0
  bond-mode 802.3ad

auto bond0
allow-hotplug bond0
iface bond0 inet dhcp
  bond-mode 802.3ad
  bond-slaves enp2s0f0 enp2s0f1
  bond-miimon 100
  bond-downdelay 200
  bond-updelay 400
```

[Reference](https://www.server-world.info/en/note?os=Debian_12&p=bonding)

### GPU Install

```bash
sudo apt install \
    nftables \
    nfs-common \
    net-tools \
    nvidia-driver-545 \
    open-iscsi \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    containerd \
    vim

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update && sudo apt install nvidia-container-toolkit
```

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
- bjw-s
- buroa
- joryirving

For all their hard work and dedication
