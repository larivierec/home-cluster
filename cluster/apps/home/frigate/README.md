# NVIDIA GPU for Frigate

1. install nerdctl on nodes with gpu
2. move it to /usr/local/bin

```bash
mkdir trt-models
wget https://raw.githubusercontent.com/blakeblackshear/frigate/dev/docker/tensorrt_models.sh
chmod +x tensorrt_models.sh
sudo nerdctl run --gpus all --rm -it -v `pwd`/trt-models:/tensorrt_models -v `pwd`/tensorrt_models.sh:/tensorrt_models.sh nvcr.io/nvidia/tensorrt:22.07-py3 /tensorrt_models.sh
```

these tensor RT models are used in frigate.
must be mounted by a PVC and not committed to Git repository.

These files are specific to the installed GPU.

They should look like this.

```bash
-rwxr-xr-x  1 user user    93040 Mar 14 18:23 libyolo_layer.so*
-rw-r--r--  1 user user 33733550 Mar 14 18:26 yolov4-tiny-288.trt
-rw-r--r--  1 user user 41999852 Mar 14 18:26 yolov4-tiny-416.trt
-rw-r--r--  1 user user 37133752 Mar 14 18:27 yolov7-tiny-416.trt
```


# Running

If everything works, you should see that detection is going through `nvidia-smi`.

```bash
christopher@k8s-gpu:~$ nvidia-smi
Tue Mar 14 18:40:37 2023
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 515.86.01    Driver Version: 515.86.01    CUDA Version: 11.7     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0 Off |                  N/A |
|  6%   52C    P2    35W / 151W |    681MiB /  8192MiB |      1%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A   2661534      C   frigate.detector.tensorrt         335MiB |
|    0   N/A  N/A   2661551      C   ffmpeg                            171MiB |
|    0   N/A  N/A   2661556      C   ffmpeg                            171MiB |
+-----------------------------------------------------------------------------+
```