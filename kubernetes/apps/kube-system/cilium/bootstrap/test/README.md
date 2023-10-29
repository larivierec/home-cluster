# cilium
use values in this folder
to enable cgroupv2 follow below instructions https://github.com/abiosoft/colima/issues/663

# colima - TLDR;

## Rerun every cilium launch locally

colima ssh -- sudo mount -t bpf bpffs /sys/fs/bpf
colima ssh -- sudo mount --make-shared /sys/fs/bpf
colima ssh -- sudo mkdir -p /run/cilium/cgroupv2
colima ssh -- sudo mount -t cgroup2 none /run/cilium/cgroupv2
colima ssh -- sudo mount --make-shared /run/cilium/cgroupv2
colima ssh -- sudo mount --make-shared /