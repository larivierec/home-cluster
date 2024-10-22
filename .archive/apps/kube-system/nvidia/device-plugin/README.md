## nvidia-daemonset-plugin

1. Simply follow instructions on installing the nvidia driver to the node. *Must be done before flux is installed*

As of k3s+1.23, k3s searches for the nvidia drivers every time the services on the cluster are started.

- /usr/local/nvidia -> this location is used by the gpu-operator (which I don't use)
- /usr/bin/nvidia-container-runtime -> this is the location used usually when using package manager installation

When the service is started, k3s will automatically add the proper binary to the `config.toml` file
