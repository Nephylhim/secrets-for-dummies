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
- `03-pbkdf2/` — PBKDF2-HMAC-SHA512 hashing (`pbkdf2-command.sh`, 220 000 iterations,
  no salt, hashcat's `sha512:iterations:salt:hash` format) and cracking
  (`crack-hashes.sh`, mode `-m 12100`).

Each `*/hashes.txt` (or `md5.hash`) file is generated output, not hand-written;
regenerate it by re-running the corresponding `hash-command.sh` /
`sha512-command.sh` / `pbkdf2-command.sh` script. `*/cracked.txt` is also
generated output from `crack-hashes.sh` and safe to delete/regenerate.

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

Each algorithm directory has a `justfile` wrapping its two scripts:
`just hash` regenerates `hashes.txt` from `../passwords.txt`, `just crack`
runs the hashcat cracking attempt, `just clean` removes `cracked.txt`, and
plain `just` runs `hash` + `crack` in order.

```bash
cd 01-md5 && just        # or: ./hash-command.sh && ./crack-hashes.sh
cd 02-sha512 && just      # or: ./sha512-command.sh && ./crack-hashes.sh
cd 03-pbkdf2 && just      # or: ./pbkdf2-command.sh && ./crack-hashes.sh
```

Cracked plaintexts are written to `cracked.txt` in each algorithm directory.

## Conventions

- Scripts are POSIX-ish bash, executable (`chmod +x`), called from within
  their own directory (they reference `../passwords.txt` / `../example.dict`
  relative to `$(pwd)`). `just` changes into the justfile's directory before
  running recipes, so this still holds when invoked via `just`.
- Call the system `hashcat` binary directly (no `HASHCAT_DIR` env var, no
  `hashcat.exe`/Windows build).
- Keep hash mode numbers (`-m`) in sync with hashcat's mode for the
  algorithm used in that directory (MD5 = 0, SHA-512 = 1700,
  PBKDF2-HMAC-SHA512 = 12100).
- Each algorithm directory's `justfile` wraps its two existing scripts
  (`hash` → `*-command.sh`, `crack` → `crack-hashes.sh`) plus a `clean`
  recipe (`rm -f cracked.txt`); keep recipe names consistent across
  directories and update it if a script is renamed.

## Scope / ethics

This repo is for learning how hashing and password cracking work, using
only locally generated sample data. Do not use it against real/third-party
credentials.

## Slides (`slides/`)

The talk **« Secrets pour les nuls »** (French) is a Typst + touying deck.

**Goal of the talk:** approach security from the *attacker's point of view*
and make the attacker's job harder step by step, each slide adding a measure
or complexity (plaintext → encryption → hash → slow hash → rainbow tables vs
salt → dictionary/brute force vs strong passwords → pepper → …). Keep this
narrative order: never use a concept (bcrypt, Argon2id, pepper…) before it
has been introduced (open items are in `slides/todo.md`).

Files:
- `slides/main.typ`: the whole deck. `slides/dummies-theme.typ`: custom theme.
- `slides/plan.md`: the author's plan. `slides/todo.md`: remaining work.
- `slides/rsc/`: images; `rsc/icons/`: OpenMoji SVGs (no emoji font installed).
- `slides/justfile`: `just build`, `just watch`, `just notes`
  (`main-notes.pdf` with speaker notes, via `--input notes=1`).

Conventions:
- Slides and commit messages are in **French**.
- Every source is cited on the slide as a **clickable `#link(url)[…]`**.
- Personal remarks and extra material go in `#speaker-note[…]`, not on slides.
- Slide headings are numbered by section (`== 2.11 - Poivre`); renumber the
  following ones when inserting a slide. The footer counter skips title and
  section slides.
- Header/footer use absolute sizes (22pt base) so a `#set text(size: …)`
  inside a slide never changes them.
- Helpers in `main.typ`: `tbox`, `mono`, `db-table` (2 columns only; use
  `table` otherwise), `arrow`, `diff-hex`.
- If a slide overflows, Typst silently adds a page with the same title: after
  building, check consecutive pages for duplicate titles
  (`pdftotext -f N -l N main.pdf - | head -1`) and shrink the content.
- Preview a page: `typst compile main.typ /tmp/p{n}.png --ppi 60`.
- Figures must be verifiable (OWASP, NIST, hashcat benchmark…); flag
  anything computed or inferred (e.g. PBKDF2 speed extrapolated from 999
  iterations).

