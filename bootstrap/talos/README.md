# Talos Journey

## pre-requisites

```bash
brew install helm
brew install kubectl
brew install talhelper
brew install talosctl
```

1. install from ISO without CNI or Kube-Proxy
2. Following commands

```bash
talhelper gensecrets > talsecrets.sops.yaml
sops -e -i talsecrets.sop.yaml 
talosctl apply-config --insecure -n <node ip> -e <endpoint from talconfig.yaml> --file ./clusterconfig/<node>.yaml
```

3. At this point, if it's the first control plane it'll try and start. ETCD will not be running and will mention that you need to start talos in bootstrap. This only needs to be done once.

```bash
talosctl bootstrap -e <endpoint from taloconfig.yaml> -n <node ip of ONE control plane> --talosconfig ./clusterconfig/<node>.yaml
talosctl kubeconfig -n 192.168.50.2 -e 192.168.50.250 --talosconfig ./clusterconfig/talosconfig ~/.kube/clusters/talos.yaml
```

4. kubeconfig will allow you to start executing kubectl commands.
5. this will allow the full control plane to start up.
6. apply your helm file or your base helm installs (cilium, coredns, prometheus crds...)

```bash
helmfile apply
```
7. If your cilium pod is having trouble starting, i.e. crashloop backoffs, approve the CSRs manually so you can check the logs of your pods.

```bash
kubectl get csr
kubectl certificate approve csr-<id>
```
