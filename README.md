<div align="center">

<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="center" width="144px" height="144px"/>

### My home Kubernetes cluster

</div>

<br/>

<div align="center">

[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?style=for-the-badge&logo=renovatebot&logoColor=white)](https://github.com/renovatebot/renovate)
  
</div>

<div align="center">

[![Plex](https://img.shields.io/uptimerobot/status/m789484250-8e4e1f5e11033c62cd18d1dc?label=my-plex&logo=plex)](https://plex.tv)
[![Home-Assistant](https://img.shields.io/uptimerobot/status/m789483406-6089c85ad33bdfdc889ae5a7?logo=homeassistant&logoColor=white&label=my%20home%20assistant)](https://www.home-assistant.io/)

Thanks to the awesome community @ k8s-at-home for their help in getting this setup.
Find their discord here.
  
[![Discord](https://img.shields.io/discord/673534664354430999?color=7289da&label=DISCORD&style=for-the-badge)](https://discord.gg/sTMX7Vh)

</div>

## Some additions added for microk8s

- K8s 1.22+ -> https://github.com/kubernetes/kubernetes/issues/87198 
> Add this to the `calico-config` in the config maps for kube-system

## Calico

```json
"container_settings": {
    "allow_ip_forwarding": true
}
```

## Ingress

This will allow wireguard pods to properly forward packets.
For ingress controller we need to add this in order to get proper ip address from Cloudflare LB @ L7.

```yml
data:
  use-forwarded-headers: "true"
```

## Feature Gates
Set the following FeatureGates
`--feature-gates=RemoveSelfLink=false,MixedProtocolLBService=true`

## nvidia gpu-operator install
disable nouveau
```bash
lsmod | grep nouveau
sudo apt-get purge xserver-xorg-video-nouveau
sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo update-initramfs -u
cat /etc/modprobe.d/blacklist-nvidia-nouveau.conf

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

### If you are using pre-installed drivers + toolkit

ensure you set the /var/snap/microk8s/current/args/containerd-template.toml
default runtime to `nvidia-container-runtime` on your GPU Node

After modify this file restart the microk8s containerd service.
`sudo systemctl restart snap.microk8s.daemon-containerd.service`

## Flux

Might have to download the flux version `install.yml` from its release.
i.e. : https://github.com/fluxcd/flux2/releases

```bash
flux install --version="${VERSION}" \
          --components-extra=image-reflector-controller,image-automation-controller \
          --network-policy=false \
          --export > ./cluster/base/flux-system/gotk-components.yaml
```
