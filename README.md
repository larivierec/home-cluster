# Some additions added for microk8s

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
