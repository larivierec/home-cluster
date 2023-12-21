# unifi

For ubiquiti, there are a few things that we need to do in order for AP's to be discoverable by the unifi-controller in k8s

1. Deploy a `load balancer` type service that exposes 10001 (UDP)
2. Set option `43` for DHCP to this IP address in hexadecimal -> see this [documentation](https://medium.com/@reefland/migrating-unifi-network-controller-from-docker-to-kubernetes-5aac8ed8da76)

My DHCP is on my router therefore, this is where I set the option.

## Notes from the website + Original author
The value 01:04:c0:a8:0a:f2 is the IP address of the UniFi Network Controller converted to Hexadecimal and a standard prefix.

    The prefix is 01:04: and this DHCP option will always start with this for UniFi devices.
    The remaining c0:a8:0a:f2 is the hexadecimal version of the IP address. If its hard to imagine it, then think of it like c0.a8.0a.f2 now convert each value from Hex to Decimal. 
    You can use the Bash shell to convert numbers, to convert c0 to decimal:

```bash
$ echo $((16#c0)) 
192
```