# Talos Journey

## Prerequisites

```bash
brew install age helm kubectl sops talosctl
brew tap mirceanton/taps
brew install talstomize
```

`talstomize.yaml` is the source for rendered machine configurations. The
encrypted `talsecret.sops.yaml` remains the source of truth for this cluster's
Talos credentials.

## Render and validate configuration

Run these commands from this directory:

```bash
talstomize build . -o ./clusterconfig

for config in ./clusterconfig/talos-m*.yaml; do
  talosctl validate --mode metal --config "$config"
done
```

The rendered files contain private keys and are ignored by Git. Do not commit
or log them. Compare the desired configuration with the live cluster before
applying changes:

```bash
talstomize diff -f .
```

## Initial cluster setup

1. Boot each machine from a Talos 1.14 Image Factory ISO without CNI or
   kube-proxy.
2. Apply each rendered configuration from maintenance mode:

```bash
talstomize apply -f . --node talos-m1 -- --insecure
talstomize apply -f . --node talos-m2 -- --insecure
talstomize apply -f . --node talos-m3 -- --insecure
```

3. Bootstrap etcd once, using one control-plane node:

```bash
talosctl bootstrap \
  --endpoints 192.168.60.5 \
  --nodes 192.168.60.5 \
  --talosconfig ./clusterconfig/talosconfig
```

4. Retrieve the Kubernetes configuration:

```bash
talosctl kubeconfig \
  --nodes 192.168.60.5 \
  --endpoints 192.168.60.250 \
  --talosconfig ./clusterconfig/talosconfig \
  ~/.kube/clusters/garb.yaml
```

5. Install the post-bootstrap components:

```bash
helmfile -f ./helmfile.yaml apply
```

## Upgrades

Talstomize reconciles machine configuration; it does not upgrade the running
Talos or Kubernetes versions. Tuppr performs those upgrades from the resources
under `../kubernetes/main/apps/system-upgrade/tuppr/upgrades/`.

Review the generated configuration and cluster health before allowing the
Talos 1.14 and Kubernetes 1.37 resources to reconcile. Talos 1.14 changes
several legacy fields to deprecated compatibility fields, but this
configuration intentionally retains them until Talstomize supports the 1.14
machinery and native documents.

## Troubleshooting CSRs

```bash
kubectl get csr
kubectl certificate approve csr-<id>
```