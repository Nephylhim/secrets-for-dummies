# AGENT.md

## Project overview

`secrets-for-dummies` is a small educational repo demonstrating password
hashing and hash-cracking with [hashcat](https://hashcat.net/hashcat/).
It hashes a local wordlist (`passwords.txt`) with different algorithms and
then recovers the plaintexts from the hashes using a dictionary attack
against `example.dict`.

Layout:
- `passwords.txt` — plaintext sample passwords used as input.
- `example.dict` — dictionary/wordlist used for cracking attempts.
- `01-md5/` — MD5 hashing (`hash-command.sh`) and cracking (`crack-hashes.sh`, mode `-m 0`).
- `02-sha512/` — SHA-512 hashing (`sha512-command.sh`) and cracking (`crack-hashes.sh`, mode `-m 1700`).

Each `*/hashes.txt` (or `md5.hash`) file is generated output, not hand-written;
regenerate it by re-running the corresponding `hash-command.sh` /
`sha512-command.sh` script. `*/cracked.txt` is also generated output from
`crack-hashes.sh` and safe to delete/regenerate.

## Environment

Developed and run on **WSL2 (Ubuntu 24.04)** with an NVIDIA GPU
(RTX 4080). GPU acceleration uses hashcat's **CUDA** backend — WSL exposes
the host GPU driver via `/usr/lib/wsl/lib/libcuda.so`, so hashcat only needs
the CUDA runtime compiler (`libnvrtc`) installed inside the distro, not a
full Linux display driver.

## Setup

```bash
# hashcat itself
sudo apt update
sudo apt install -y hashcat

# CUDA toolkit for WSL (provides libnvrtc for hashcat's CUDA backend)
# Use NVIDIA's WSL-Ubuntu repo, NOT a driver-bundled CUDA/driver package —
# WSL already provides the GPU driver, installing another one will conflict.
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y cuda-toolkit-12-6
```

Verify GPU detection:

```bash
hashcat -I   # should list a "CUDA Info" section with the NVIDIA GPU
hashcat -b   # benchmark
```

## Usage

```bash
cd 01-md5 && ./hash-command.sh && ./crack-hashes.sh
cd 02-sha512 && ./sha512-command.sh && ./crack-hashes.sh
```

Cracked plaintexts are written to `cracked.txt` in each algorithm directory.

## Conventions

- Scripts are POSIX-ish bash, executable (`chmod +x`), called from within
  their own directory (they reference `../passwords.txt` / `../example.dict`
  relative to `$(pwd)`).
- Call the system `hashcat` binary directly (no `HASHCAT_DIR` env var, no
  `hashcat.exe`/Windows build).
- Keep hash mode numbers (`-m`) in sync with hashcat's mode for the
  algorithm used in that directory (MD5 = 0, SHA-512 = 1700).

## Scope / ethics

This repo is for learning how hashing and password cracking work, using
only locally generated sample data. Do not use it against real/third-party
credentials.
