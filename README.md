# Some additions added for microk8s

- K8s 1.22+ -> https://github.com/kubernetes/kubernetes/issues/87198 
-> Add this to the `calico-config` in the config maps for kube-system

```json
"container_settings": {
    "allow_ip_forwarding": true
}
```

This will allow wireguard pods to properly forward packets.
For ingress controller we need to add this in order to get proper ip address from Cloudflare LB @ L7.

```yml
data:
  use-forwarded-headers: "true"
```

Set the following FeatureGates
|--feature-gates=RemoveSelfLink=false,MixedProtocolLBService=true
