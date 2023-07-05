<div align="center">

<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="center" width="144px" height="144px"/>

### Home Kubernetes cluster

</div>

<br/>

<div align="center">

[![k3s](https://img.shields.io/badge/k3s-v1.27-brightgreen?style=for-the-badge&logo=kubernetes&logoColor=white)](https://k3s.io/)
[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?style=for-the-badge&logo=renovatebot&logoColor=white)](https://github.com/renovatebot/renovate)
  
</div>

<div align="center">

[![Home-Assistant](https://img.shields.io/uptimerobot/status/m789483406-6089c85ad33bdfdc889ae5a7?logo=homeassistant&logoColor=white&label=my%20home%20assistant)](https://www.home-assistant.io/)
[![Overseerr](https://img.shields.io/uptimerobot/status/m789483603-29e0e1966ab760983f46ed3c?label=Overseerr)](https://overseerr.dev/)
[![Internet](https://img.shields.io/uptimerobot/status/m789484238-7de3cf2b8346bbd39dfca242?logo=opnsense&logoColor=white&label=opnsense)](https://opnsense.org/)


Thanks to the awesome community @ k8s-at-home for their help in getting this setup.
Find their discord here.
  
[![Discord](https://img.shields.io/discord/673534664354430999?color=7289da&label=DISCORD&style=for-the-badge)](https://discord.gg/sTMX7Vh)

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

## Cilium

4. Optionally, install the cilium-cni and execute:

```bash
cilium install
```

4. I recommend to use bootstrap values from kubernetes/core/cilium/bootstrap/values.yaml

```bash
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium -f kubernetes/core/cilium/bootstrap/values.yaml --namespace kube-system
```

## Cilium CNI - Note
Be sure to set the Pod CIDR to the one you have chosen if you aren't using the k3s default. `10.42.0.0/16`
Otherwise, you will more than likely have issues.

The APIServer address must also be correct otherwise, the cni will not be installed on the nodes.
I have the three master node IP addresses registered to the HAProxy on my router on port 6443.

## nvidia-daemonset-plugin

1. Simply follow instructions on installing the nvidia driver to the node. *Must be done before flux is installed*

As of k3s+1.23, k3s searches for the nvidia drivers everytime the services on the cluster are started.

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

3. Add these secrets

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

## Ingress

For ingress controller we need to add this in order to get proper ip address from Cloudflare LB @ L7.

```yml
data:
  use-forwarded-headers: "true"
  forwarded-for-header: "CF-Connecting-IP"
```

# Nodes/Hardware


| Device                    | Count | OS Disk Size            | Data Disk Size              | Ram  | Operating System | Purpose              |
| --------------------------|-------|-------------------------|-----------------------------|------|------------------|--------------------- |
| J4125 RS34g               | 1     | 250Gi mSATA             | -                           | 16Gi | Opnsense 23      | Router               |
| Beelink U59 N5105         | 3     | 500Gi M2 SATA           | -                           | 16Gi | Ubuntu 22.04     | Kubernetes Masters   |
| NVIDIA - GPU PC  (1)      | 1     | 2Ti   NVMe              | -                           | 32Gi | Proxmox 7.2      | Virtual Machine      |
| NVIDIA - GPU PC  (2)      | 1     | 500Gi NVMe              | -                           | 32Gi | Proxmox 7.2      | Virtual Machine      |
| Synology 920+             | 1     | 26Ti  HDD / 2Ti NVMe    | -                           | 4Gi  | DSM 7            | NAS                  |

| VMs                       | Count | Ram         | Operating System  | Purpose             |
| --------------------------|-------|-------------|-------------------|-------------------- |
| k3s-worker-#              | 3     | 12Gi / 8 Gi | Ubuntu 22.04      | Kubernetes Workers  |
| k3s-worker-gpu-#          | 2     | 16Gi        | Ubuntu 22.04      | Kubernetes Workers  |


# Notes

## Frigate

I suggest you check the frigate folder for more information regarding nvidia detection.

## Proxmox

GPU Passthrough

1. VT-d enabled in motherboard BIOS
2. Follow instructions here: https://gist.github.com/qubidt/64f617e959725e934992b080e677656f
3. Add the PCI-E gpu to the VM
4. install

```bash
apt-get install \
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
For Z390 there were no issues.
For X99-Deluxe-ii motherboard, gpu-passthrough has issues with Kernel 5.15.104-1+. When the node is booted it needs to execute

See [GPU Passthrough - Workaround](https://forum.proxmox.com/threads/gpu-passthrough-issues-after-upgrade-to-7-2.109051/#post-469855)
Intel I219 passthrough

```bash
ethtool -K eno1 gso off gro off tso off tx off rx off rxvlan off txvlan off sg off
```

```bash

if [ $2 == "pre-start" ]
then
    echo "gpu-hookscript: Resetting GPU for Virtual Machine $1"
    echo 1 > /sys/bus/pci/devices/0000\:01\:00.0/remove
    echo 1 > /sys/bus/pci/rescan
fi

```

## Beelink nodes

For Beelink nodes, there was an incompatibility for iGPU transcoding with Ubuntu 22.04.1 LTS and Kernel 5.15.X

To fix this, install a Kernel with the patch:

Beelink U59 uses amd64 architecture.
[unsigned image](https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.16/amd64/linux-image-unsigned-5.16.0-051600-generic_5.16.0-051600.202201092355_amd64.deb)
[modules](https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.16/amd64/linux-modules-5.16.0-051600-generic_5.16.0-051600.202201092355_amd64.deb)

1. Add the file /etc/modprobe.d/i915.conf containing the following.

```text
options i915 enable_guc=3
```

2. Update grub to take into account the i915 configuration
```bash
sudo update-initramfs -u && sudo update-grub2
```

3. Reboot

4. When everything has reloaded, check the `dmesg` ensure that it loads and something similar should show up in the logs
```text
[    1.294988] i915 0000:00:02.0: vgaarb: deactivate vga console
[    1.296988] i915 0000:00:02.0: vgaarb: changed VGA decodes: olddecodes=io+mem,decodes=io+mem:owns=io+mem
[    1.297508] i915 0000:00:02.0: [drm] Finished loading DMC firmware i915/icl_dmc_ver1_09.bin (v1.9)
[    1.318551] i915 0000:00:02.0: [drm] GuC firmware i915/ehl_guc_62.0.0.bin version 62.0 submission:enabled
[    1.318560] i915 0000:00:02.0: [drm] GuC SLPC: disabled
[    1.318563] i915 0000:00:02.0: [drm] HuC firmware i915/ehl_huc_9.0.0.bin version 9.0 authenticated:yes
```
