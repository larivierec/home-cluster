# Tailscale Operator

While the concept is nice, I don't like have 1 pod for each service that I expose.

tailscale operator requires the use of these 2 annotations on services
```
    tailscale.com/expose: "true"
    tailscale.com/hostname: name
```

it will create a single pod for each service that you decide to expose

```
tailscale-c4b698657-4cn4c             1/1     Running   0          3d13h <---- normal tailscale proxy
tailscale-operator-6c449755f7-74hr5   1/1     Running   0          32m   <---- operator creating the pods below
ts-radarr-m6vrz-0                     1/1     Running   0          44s   <---- tailscale pod for radarr
ts-sonarr-vflsx-0                     1/1     Running   0          32s   <---- tailscale pod for sonarr
```

I'd rather have a single pod, broadcast the subnet and can be used as an exit node for my devices
This way, it acts as a gateway for the cluster.

In both cases, you need to modify your ACL policy in Tailscale console anyway.

## Future

In a future version, if the operator is able to create a tailscale pod to broadcast a subnet and act as an exit node, I will be using this instead of the custom gateway setup.