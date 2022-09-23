<div align="center">

<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="center" width="144px" height="144px"/>

### Home Kubernetes cluster

</div>

<br/>

<div align="center">

[![k3s](https://img.shields.io/badge/k3s-v1.24.4-brightgreen?style=for-the-badge&logo=kubernetes&logoColor=white)](https://k3s.io/)
[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?style=for-the-badge&logo=renovatebot&logoColor=white)](https://github.com/renovatebot/renovate)
  
</div>

<div align="center">

[![Home-Assistant](https://img.shields.io/uptimerobot/status/m789483406-6089c85ad33bdfdc889ae5a7?logo=homeassistant&logoColor=white&label=my%20home%20assistant)](https://www.home-assistant.io/)

Thanks to the awesome community @ k8s-at-home for their help in getting this setup.
Find their discord here.
  
[![Discord](https://img.shields.io/discord/673534664354430999?color=7289da&label=DISCORD&style=for-the-badge)](https://discord.gg/sTMX7Vh)

</div>

# k3s

## Setup

This setup uses calico cni as a networking backend.
k3s cluster will also be configured as an HA using etcd with the `--cluster-init` flag

## Config File

### Server

1. Install k3s manually
```bash
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s - --flannel-backend none --disable traefik --disable servicelb --disable-network-policy --kube-controller-manager-arg bind-address=0.0.0.0 --kube-controller-manager-arg bind-address=0.0.0.0 --kube-proxy-arg bind-address=0.0.0.0 --kube-scheduler-arg bind-address=0.0.0.0 --kube-scheduler-arg bind-address=0.0.0.0 --expose-etcd-metrics=true --cluster-init
```
2. Immediately stop the k3s cluster after it's up
3. In the `/var/lib/rancher/k3s/server/manifests` folder download `https://projectcalico.docs.tigera.io/master/manifests/calico.yaml`
4. Modify the calico-config at the top of the file to include
```yaml
"container_settings": {
  "allow_ip_forwarding": true
}
```
5. Restart the cluster.

### Worker

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN="" K3S_URL=https://<ip:port> sh -
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
  --path=./clusters/base \
  --personal
```

2. Install the sops secret either gpg or age [sops age](https://fluxcd.io/docs/guides/mozilla-sops/#encrypting-secrets-using-age)

```bash
age-keygen -o age.agekey

cat age.agekey |
kubectl create secret generic sops-age \
--namespace=flux-system \
--from-file=age.agekey=/dev/stdin
```

3. Ensure you use this `sops-age` secret for decrypting.

## Ingress

For ingress controller we need to add this in order to get proper ip address from Cloudflare LB @ L7.

```yml
data:
  use-forwarded-headers: "true"
  forwarded-for-header: "CF-Connecting-IP"
```

## nvidia gpu-operator install + nvidia-daemonset

Stop the cluster before doing anything with the GPU

1. disable nouveau (default driver ubuntu)

```bash
lsmod | grep nouveau
sudo apt-get purge xserver-xorg-video-nouveau
sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo update-initramfs -u
cat /etc/modprobe.d/blacklist-nvidia-nouveau.conf
```

2. Download [device-plugin-daemonset.yaml](https://k3d.io/v5.4.1/usage/advanced/cuda/device-plugin-daemonset.yaml) to folder `/var/lib/rancher/k3s/server/manifests/`
3. Add [config.toml.tmpl](https://k3d.io/v5.4.1/usage/advanced/cuda/?h=container#configure-containerd) to `/var/lib/rancher/k3s/agent/etc/containerd` and restart the cluster
4. Remove these labels from the nodes

```
kubectl label --overwrite \
        node ${NODE_NAME} \
        nvidia.com/gpu.deploy.operator-validator=false \
        nvidia.com/gpu.deploy.driver=false \
        nvidia.com/gpu.deploy.container-toolkit=false \
        nvidia.com/gpu.deploy.device-plugin=false \
        nvidia.com/gpu.deploy.gpu-feature-discovery=false \
        nvidia.com/gpu.deploy.dcgm-exporter=false \
        nvidia.com/gpu.deploy.dcgm=false
```
