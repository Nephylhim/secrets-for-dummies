# secrets-for-dummies

A small educational repo demonstrating password hashing (MD5, SHA-512) and
GPU-accelerated hash cracking with [hashcat](https://hashcat.net/hashcat/).

## Setup (WSL2 + NVIDIA GPU)

Tested on WSL2 (Ubuntu 24.04) with an NVIDIA GPU. WSL already exposes the
host's GPU driver to Linux, so you only need to install `hashcat` and the
CUDA runtime compiler (`libnvrtc`) it uses for GPU acceleration — **do not**
install a Linux NVIDIA display driver or a driver-bundled CUDA package, as
that will conflict with WSL's own GPU passthrough.

```bash
# hashcat
sudo apt update
sudo apt install -y hashcat

# CUDA toolkit for WSL (provides libnvrtc for hashcat's CUDA backend)
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y cuda-toolkit-12-6
```

Verify the GPU is detected:

```bash
hashcat -I   # look for a "CUDA Info" section listing your NVIDIA GPU
hashcat -b   # benchmark
```

## Usage

```bash
cd 01-md5 && ./hash-command.sh && ./crack-hashes.sh
cd 02-sha512 && ./sha512-command.sh && ./crack-hashes.sh
```

Cracked plaintexts are written to `cracked.txt` in each algorithm's
directory.