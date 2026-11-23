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

## Slides (`slides/`)

The repo also contains the slides of the talk **« Secrets pour les nuls »**
(in French), written with [Typst](https://typst.app/) and
[touying](https://typst.app/universe/package/touying/).

The goal of the talk is to approach security **from the attacker's point of
view**: we start from a plaintext database, then add measures one by one
(hash, slow hash, salt, pepper…), each one making the attacker's work harder.

```bash
cd slides
just build   # main.pdf
just watch   # recompile on change
just notes   # main-notes.pdf: slides + speaker notes on a second screen
```

- `main.typ`: the deck. `dummies-theme.typ`: custom theme (yellow / black / cream).
- `plan.md`: the original plan. `todo.md`: remaining work.
- `rsc/`: images and icons.
