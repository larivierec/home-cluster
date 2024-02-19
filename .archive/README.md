# Proxmox Passthru

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

### Network Bonding

#### Debian

2. open `/etc/network/interfaces` as root or privileged and add the following

```text
auto enp2s0f0
iface enp2s0f0 inet manual
  bond-master bond0
  bond-mode 802.3ad

auto enp2s0f1
iface enp2s0f1 inet manual
  bond-master bond0
  bond-mode 802.3ad

auto bond0
iface bond0 inet dhcp
  bond-mode 802.3ad
  bond-slaves enp2s0f0 enp2s0f1
  bond-miimon 100
  bond-downdelay 200
  bond-updelay 400
```

[Reference](https://www.server-world.info/en/note?os=Debian_12&p=bonding)

### Kernel 6.5.X HWE woes

#### Frigate Install - PCIe TPU

For Kernel 6.5.X HWE more instability was detected.

```bash
sudo apt remove gasket-dkms
sudo apt install git -y
sudo apt install devscripts -y
sudo apt install dkms -y # dh-dkms on debian
sudo apt install debhelper -y

git clone https://github.com/google/gasket-driver.git
cd gasket-driver/
debuild -us -uc -tc -b
cd ..
sudo dpkg -i gasket-dkms_1.0-18_all.deb

sudo apt update && sudo apt upgrade -y
```

Then reboot.
This allows us to build the module for the new kernel

[Reference](https://forum.proxmox.com/threads/update-error-with-coral-tpu-drivers.136888/#post-608975)

#### Note

Package `r8168-dkms` is no longer required as of kernel 6.5.X it uses r8169.

If you upgrade to this security update and it restarts [Kernel version missing from 8.0.48.0](https://github.com/mtorromeo/r8168/blob/master/src/r8168_n.c#L84-L86) the driver will not load and you
will no longer have network access.

If ubuntu is already installed and you do not want to reinstall the OS download r8168 [R8168 - Build From Source + Autorun](https://github.com/mtorromeo/r8168/archive/refs/tags/8.052.01.tar.gz)
