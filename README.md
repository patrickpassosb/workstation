# workstation

Automated setup scripts for Ubuntu-based Linux workstations (Pop!_OS, Ubuntu, Linux Mint, etc.).

Choose a **phase** and **level** to control how much gets compiled from source vs. installed pre-built. Like a game — progress from Level 0 (everything pre-built) to Phase 10 Level 10 (custom OS on RISC-V bare metal).

## Quick start

```bash
git clone https://github.com/patrickpassosb/workstation.git
cd workstation
./setup.sh                              # interactive: asks phase + level
./setup.sh --phase 1 --level 0          # all pre-built, fastest install
./setup.sh --phase 1 --level 2          # compile 10 Go/Node.js CLIs, rest pre-built
./setup.sh --phase 1 --level 10         # compile all Phase 1 tools from source
```

## Phase 1: CLI Tools & Small Apps (implemented)

*Any laptop. No special hardware needed.*

| Level | Name | What gets compiled | Cumulative |
|-------|------|--------------------|------------|
| **0** | Pre-built | Nothing — all apt/npm/flatpak/GitHub releases | 0 tools |
| **1** | First steps | 6 Node.js CLIs (codex, claude-code, gemini-cli, kilo-cli, vercel-cli, context-hub) | 6 tools |
| **2** | Go basics | + 4 Go CLIs (fzf, lazygit, lazydocker, opencode) | 10 tools |
| **3** | Rust basics | + 2 Rust CLIs (ripgrep, fd) — ~1 min each | 12 tools |
| **4** | Rust/Zig medium | + 3 heavier builds (starship, uv, bun) — 5-10 min each | 15 tools |
| **5** | Official repos | + 3 Go projects (gh, tailscale, docker CLI) | 18 tools |
| **6** | CMake & Meson | + 2 CMake/Meson apps (flameshot, easyeffects) | 20 tools |
| **7** | Autotools intro | + 2 autotools builds (htop, jq) | 22 tools |
| **8** | Core system | + 2 system tools (tmux, zsh) | 24 tools |
| **9** | Core infra | + git from source | 25 tools |
| **10** | Full source | + Node.js from source — compile everything | 26 tools |

The remaining 5 tools (OBS, GIMP, Audacity, Telegram, Bitwarden) are always pre-built in Phase 1 — they become compilable in Phase 2.

## Phases 2-10 (roadmap)

See [docs/roadmap.md](docs/roadmap.md) for the full vision:

| Phase | Layer | Hardware |
|-------|-------|----------|
| **1** | CLI Tools & Small Apps | Any laptop |
| **2** | Desktop Apps (OBS, GIMP, Brave) | 8GB+ RAM |
| **3** | Runtimes (Python, Ruby, Node.js) | Any laptop |
| **4** | Build Systems (CMake, Meson, Make) | Any laptop |
| **5** | Compilers (GCC, LLVM, Rust bootstrap) | 16GB+ RAM |
| **6** | Core System (coreutils, glibc, systemd) | VM required |
| **7** | OS Internals (kernel, bootloader, LFS) | VM required |
| **8** | Networking & Drivers (kernel modules) | VM required |
| **9** | Cross-Compilation (ARM64, RISC-V) | QEMU or dev board |
| **10** | Bare Metal (RISC-V assembly, custom OS) | QEMU or RISC-V board |

## Run individual scripts

Every tool script accepts a mode argument:

```bash
./tools/ripgrep.sh              # defaults to "build" (clone + compile)
./tools/ripgrep.sh prebuilt     # install pre-built binary via apt
./tools/ripgrep.sh clone        # clone source only + print build instructions
./tools/ripgrep.sh build        # clone + compile + install

./installers/brave.sh           # install Brave browser
./configs/restore-configs.sh    # restore dotfiles
```

## Flags

```bash
./setup.sh --phase 1 --level 5    # Phase 1, intermediate
./setup.sh --skip-tools            # skip tool installation entirely
./setup.sh --skip-installers       # skip proprietary app installers
./setup.sh --skip-configs          # skip dotfile restoration
```

## Setup phases (what happens when you run setup.sh)

| Step | What it does |
|------|-------------|
| **Preflight** | Checks internet connectivity |
| **Bootstrap** | `apt update`, installs base tools, Flathub, JetBrains Mono Nerd Font |
| **Toolchains** | Installs Rust (rustup) and Node.js version manager (nvm) |
| **Tools** | Installs 30+ tools using the selected level (prebuilt or build per tool) |
| **Installers** | Installs proprietary apps (Brave, Chrome, Cursor, Warp, Discord, etc.) |
| **Configs** | Restores shell configs, Flameshot shortcut, UFW firewall, SSH key generation |
| **Cleanup** | `apt autoclean`, `flatpak update` |

## Pre-built install methods (Level 0)

| Category | Tools | Method |
|----------|-------|--------|
| apt packages | zsh, git, tmux, htop, jq, ripgrep, fd-find, fzf | `apt install` |
| Flatpak | flameshot, OBS, GIMP, Audacity, Telegram, Bitwarden, EasyEffects | `flatpak install` |
| GitHub releases | lazygit, lazydocker, opencode | Binary download |
| Official installers | tailscale, starship, uv, bun | `curl \| sh` |
| Official apt repos | gh, docker | APT repository + `apt install` |
| npm global | codex, gemini-cli, kilo-cli, vercel-cli, context-hub, claude-code | `npm install -g` |
| nvm | Node.js | `nvm install --lts` |

## Repository structure

```
workstation/
├── setup.sh                  # main orchestrator (--phase N --level N)
├── docs/
│   └── roadmap.md            # Phases 2-10 vision & roadmap
├── lib/
│   ├── helpers.sh            # shared functions
│   └── registry.sh           # tool → build-level mappings
├── tools/                    # 31 tools, each with prebuilt/clone/build modes
│   ├── install-all.sh        # orchestrator — accepts level, uses registry
│   ├── ripgrep.sh            # Level 3  — Rust, cargo
│   ├── fd.sh                 # Level 3  — Rust, cargo
│   ├── fzf.sh                # Level 2  — Go
│   ├── lazygit.sh            # Level 2  — Go
│   ├── lazydocker.sh         # Level 2  — Go
│   ├── opencode.sh           # Level 2  — Go
│   ├── zsh.sh                # Level 8  — C, autotools
│   ├── git.sh                # Level 9  — C, make
│   ├── tmux.sh               # Level 8  — C, autotools
│   ├── htop.sh               # Level 7  — C, autotools
│   ├── jq.sh                 # Level 7  — C, autotools
│   ├── flameshot.sh          # Level 6  — C++, cmake/Qt5
│   ├── starship.sh           # Level 4  — Rust, cargo
│   ├── uv.sh                 # Level 4  — Rust, cargo
│   ├── bun.sh                # Level 4  — Zig/C++, cmake
│   ├── gh.sh                 # Level 5  — Go
│   ├── tailscale.sh          # Level 5  — Go
│   ├── docker.sh             # Level 5  — Go (CLI only)
│   ├── easyeffects.sh        # Level 6  — C++, meson/gtk4
│   ├── nodejs.sh             # Level 10 — C++, configure
│   ├── obs.sh                # Phase 2  — C++, cmake
│   ├── telegram.sh           # Phase 2  — C++, cmake
│   ├── audacity.sh           # Phase 2  — C++, cmake
│   ├── gimp.sh               # Phase 2  — C, meson
│   ├── bitwarden.sh          # Phase 2  — TypeScript/Electron
│   ├── codex.sh              # Level 1  — TypeScript, npm
│   ├── gemini-cli.sh         # Level 1  — TypeScript, npm
│   ├── kilo-cli.sh           # Level 1  — TypeScript, npm
│   ├── vercel-cli.sh         # Level 1  — TypeScript, npm
│   ├── context-hub.sh        # Level 1  — JavaScript, npm
│   └── claude-code.sh        # Level 1  — TypeScript, npm
├── installers/               # proprietary apps (always pre-built)
│   ├── install-all.sh
│   ├── rustup.sh
│   ├── nvm.sh
│   ├── homebrew.sh
│   ├── oh-my-zsh.sh
│   ├── brave.sh
│   ├── chrome.sh
│   ├── discord.sh
│   ├── zoom.sh
│   ├── cursor.sh
│   ├── warp.sh
│   ├── voquill.sh
│   ├── stayfree.sh
│   └── antigravity.sh
└── configs/
    ├── zshrc
    ├── bashrc
    ├── gitconfig
    ├── firewall.sh
    └── restore-configs.sh
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SRC_DIR` | `~/src` | Where source repos are cloned |
| `INSTALL_PREFIX` | `/usr/local` | Where from-source builds install |
| `ANTIGRAVITY_DEB_URL` | *(empty)* | Direct .deb URL for Antigravity |

## Security

- **No secrets in this repo.** Config files have tokens stripped and replaced with placeholders.
- `restore-configs.sh` prompts you to enter secrets at setup time.
- `.gitignore` blocks `*.env`, `*.secret`, and `.env*` patterns.

## Prerequisites

- An Ubuntu-based Linux distro (Pop!_OS, Ubuntu 22.04+, Linux Mint, etc.)
- Internet connection
- `sudo` access

## After setup

```bash
sudo tailscale up          # join your Tailnet
gh auth login              # authenticate GitHub CLI
cat ~/.ssh/id_ed25519.pub  # add SSH key to GitHub
```
