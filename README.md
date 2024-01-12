<div align="center">

<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="center" width="144px" height="144px" alt="kubernetes"/>

## Home Kubernetes cluster

</div>

<br/>

<div align="center">

[![Discord](https://img.shields.io/discord/673534664354430999?color=7289da&label=DISCORD&style=for-the-badge)](https://discord.gg/sTMX7Vh)
[![k3s](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flarivierec%2Fhome-cluster%2Fc4bc96fe4c540a686266c0a801d714bc966f5584%2Fkubernetes%2Fapps%2Fsystem-upgrade%2Fsystem-upgrade-controller%2Fplans%2Fserver.yaml&query=spec.version&logo=k3s&label=k3s&style=for-the-badge)](https://k3s.io)
[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?style=for-the-badge&logo=renovatebot&logoColor=white)](https://github.com/renovatebot/renovate)

</div>

<div align="center">

[![Home-Assistant](https://img.shields.io/uptimerobot/status/m789483406-6089c85ad33bdfdc889ae5a7?logo=homeassistant&logoColor=white&label=my%20home%20assistant)](https://www.home-assistant.io/)
[![Overseerr](https://img.shields.io/uptimerobot/status/m789483603-29e0e1966ab760983f46ed3c?label=Overseerr)](https://overseerr.dev/)

</div>

# k3s

## Setup

k3s cluster will also be configured as an HA using etcd with the `--cluster-init` flag

## Config File

### Server

1. Install k3s manually

```bash
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server" sh -s - --flannel-backend none \
        --disable traefik \
        --disable servicelb \
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
        --disable-network-policy \
        --disable-kube-proxy \
        --kube-controller-manager-arg bind-address=0.0.0.0 \
        --kube-scheduler-arg bind-address=0.0.0.0 \
        --etcd-expose-metrics
```

3. Add workers

### Worker

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN="" K3S_URL=https://<ip:port> sh -
```

4. I recommend to use bootstrap values from kubernetes/core/cilium/bootstrap/values.yaml

```bash
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium -f kubernetes/core/cilium/bootstrap/values.yaml --namespace kube-system
```

# OPNsense

Note: Add an entry to the BGP Neighbors table with the IP address of the Node you're adding.

## Networking

I use Tailscale on the router and another one inside the cluster.
Both of them broadcasts my network and act as exit nodes for Tailscale clients.

Router exit node
Cluster exit node

Having both isn't necessary because if you lose internet you won't be able to access either remotely.
The difference is if i'm playing around with stuff inside the cluster and the cluster breaks, I may no longer be able to use the exit node in the cluster; The exit node inside the cluster is the main exit node.

Having the ability to not put unnecessary strain on the router is the reason why i'm running 2 exit nodes + 2 subnet broadcasts.
If I have internet access and the cluster explodes for whatever reason, at least, i'll still be able to access my network remotely.

## Cilium CNI - Note

Be sure to set the Pod CIDR to the one you have chosen if you aren't using the k3s default. `10.42.0.0/16`
Otherwise, you will more than likely have issues.

The APIServer address must also be correct otherwise, the cni will not be installed on the nodes.
I have the three master node IP addresses registered to the HAProxy on my router on port 6443.

## nvidia-daemonset-plugin

1. Simply follow instructions on installing the nvidia driver to the node. *Must be done before flux is installed*

As of k3s+1.23, k3s searches for the nvidia drivers every time the services on the cluster are started.

- /usr/local/nvidia -> this location is used by the gpu-operator (which I don't use)
- /usr/bin/nvidia-container-runtime -> this is the location used usually when using package manager installation

When the service is started, k3s will automatically add the proper binary to the `config.toml` file

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

# Notes

## Unifi

As I have unifi hardware, you cannot wait for the Unifi Software controller.
You have 2 options.

1. Get a cloud key / security gateway
2. Self-host on something reliable like a NAS.

I opted for option 2 because it's cheaper and does almost the same, except you manage your own backups and etc.
When I just had APs this didn't bother me, however, now with Switches your NAS must be up and running before setting up the switch.

Maybe this could've been run on a router but I did not want to introduce more stress

## Gateway API

Ingress and Gateway API can co-exist.
Keep in mind, the DNS must simply be unique.

## Ingress

For ingress controller we need to add this in order to get proper ip address from Cloudflare LB @ L7.

```yaml
data:
  use-forwarded-headers: "true"
  forwarded-for-header: "CF-Connecting-IP"
```

# Nodes/Hardware

| Device                    | Count | OS Disk Size            | Data Disk Size              | Ram  | Operating System | Purpose              |
| --------------------------|-------|-------------------------|-----------------------------|------|------------------|--------------------- |
| J4125 RS34g               | 1     | 250Gi mSATA             | -                           | 16Gi | Opnsense 23      | Router               |
| Unifi Core Switch XG-16   | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Unifi Enterprise 24 PoE   | 1     |            -            | -                           |  -   | Unifi OS - 6.x   | Switch               |
| Beelink U59 N5105         | 3     | 500Gi M2 SATA           | -                           | 16Gi | Ubuntu 22.04     | Kubernetes Masters   |
| NVIDIA - GPU PC  (1)      | 1     | 2Ti   NVMe              | -                           | 32Gi | Proxmox 8.x      | Virtual Machine      |
| NVIDIA - GPU PC  (2)      | 1     | 500Gi NVMe              | -                           | 32Gi | Proxmox 8.x      | Virtual Machine      |
| Synology 920+             | 1     | 26Ti  HDD / 2Ti NVMe    | -                           | 4Gi  | DSM 7            | NAS                  |

| VMs                       | Count | Ram         | Operating System  | Purpose             |
| --------------------------|-------|-------------|-------------------|-------------------- |
| k3s-worker-#              | 3     | 16Gi        | Ubuntu 22.04      | Kubernetes Workers  |
| k3s-worker-gpu-#          | 2     | 16Gi        | Ubuntu 22.04      | Kubernetes Workers  |

# Base Node Install

## Proxmox / Worker Nodes

GPU Passthrough

1. VT-d enabled in motherboard BIOS
2. Follow instructions here: [Pass Thru](https://gist.github.com/qubidt/64f617e959725e934992b080e677656f)
3. Add the PCI-E gpu to the VM
4. install


For Z390 there were no issues.
For X99-Deluxe-ii motherboard, gpu-passthrough has issues with Kernel 5.15.104-1+. When the node is booted it needs to execute

See [GPU Passthrough - Workaround](https://forum.proxmox.com/threads/gpu-passthrough-issues-after-upgrade-to-7-2.109051/#post-469855)

```bash
if [ $2 == "pre-start" ]
then
    echo "gpu-hookscript: Resetting GPU for Virtual Machine $1"
    echo 1 > /sys/bus/pci/devices/0000\:01\:00.0/remove
    echo 1 > /sys/bus/pci/rescan
fi
```

## Nodes

### Base install

```bash
sudo apt install \
  nftables \
  nfs-common \
  curl \
  containerd \
  vim \
  gnupg \
  net-tools \
  dnsutils
```

### GPU Install

```bash
sudo apt install \
    nftables \
    nfs-common \
    net-tools \
    nvidia-driver-525 \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    containerd \
    vim

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Kernel 6.5.X HWE woes

#### Frigate Install - PCIe TPU

For Kernel 6.5.X HWE more instability was detected.

```bash
sudo apt remove gasket-dkms
sudo apt install git
sudo apt install devscripts
sudo apt install dkms
sudo apt install debhelper

git clone https://github.com/google/gasket-driver.git
cd gasket-driver/
debuild -us -uc -tc -b
cd ..
sudo dpkg -i gasket-dkms_1.0-18_all.deb

sudo apt update && sudo apt upgrade
```

This allows us to build the module for the new kernel

[Reference](https://forum.proxmox.com/threads/update-error-with-coral-tpu-drivers.136888/#post-608975)

#### Note

Package `r8168-dkms` is no longer required as of kernel 6.5.X it uses r8169.

If you upgrade to this security update and it restarts [Kernel version missing from 8.0.48.0](https://github.com/mtorromeo/r8168/blob/master/src/r8168_n.c#L84-L86) the driver will not load and you
will no longer have network access.

If ubuntu is already installed and you do not want to reinstall the OS download r8168 [R8168 - Build From Source + Autorun](https://github.com/mtorromeo/r8168/archive/refs/tags/8.052.01.tar.gz)


## ⭐ Stargazers

[![Star History Chart](https://api.star-history.com/svg?repos=larivierec/home-cluster&type=Date)](https://star-history.com/#larivierec/home-cluster&Date)

## 🤝 Gratitude and Thanks

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) Discord community. Be sure to check out [kubesearch.dev](https://kubesearch.dev/) for ideas on how to deploy applications or get ideas on what you may deploy.

- onedr0p
- bjw-s

For all their hard work and dedication
