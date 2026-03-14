# workstation

Automated setup scripts for Ubuntu-based Linux workstations (Pop!_OS, Ubuntu, Linux Mint, etc.).

Builds most tools **from source** for learning purposes, with proprietary apps installed via their official channels. Every script is idempotent and can run individually or as part of the full orchestrated setup.

## Quick start

```bash
git clone https://github.com/patrickpassosb/workstation.git
cd workstation
./setup.sh
```

The orchestrator runs in 6 phases and will prompt for `sudo` as needed.

### Flags

```bash
./setup.sh --skip-source      # skip all from-source builds
./setup.sh --skip-installers   # skip proprietary installers
./setup.sh --skip-configs      # skip dotfile restoration
```

## Run individual scripts

Every script is standalone. To build just one tool:

```bash
./from-source/htop.sh       # build htop from source
./installers/brave.sh        # install Brave browser
./configs/restore-configs.sh # restore dotfiles (backs up existing ones first)
```

## Execution phases

| Phase | What it does |
|-------|-------------|
| **0 - Preflight** | Checks internet connectivity |
| **1 - Bootstrap** | `apt update`, installs base tools (`build-essential`, `curl`, `flatpak`, etc.), creates productivity folders, installs JetBrains Mono Nerd Font |
| **2 - Rustup** | Installs Rust toolchain (needed for building uv, ripgrep, fd, starship) |
| **3 - From-source** | Builds 30 tools from source (C, Rust, Go, TypeScript) |
| **4 - Installers** | Installs proprietary/packaged apps (Brave, Chrome, Cursor, Warp, Discord, etc.) |
| **5 - Configs** | Restores shell configs, configures Flameshot as Print Screen, SSH key generation |
| **6 - Cleanup** | `apt autoclean`, `flatpak update`, prints summary |

## Repository structure

```
workstation/
├── setup.sh                  # main orchestrator
├── lib/
│   └── helpers.sh            # shared functions (log, clone_or_pull, ensure_build_deps, etc.)
├── configs/
│   ├── zshrc                 # sanitized .zshrc (secrets stripped)
│   ├── bashrc                # sanitized .bashrc (secrets stripped)
│   ├── gitconfig             # git config (uses gh auth, no tokens)
│   └── restore-configs.sh    # backs up existing configs, copies these, prompts for secrets
├── from-source/
│   ├── install-all.sh        # orchestrator for all from-source builds
│   ├── zsh.sh                # C, autotools
│   ├── git.sh                # C, make
│   ├── nodejs.sh             # C++, configure/make
│   ├── uv.sh                 # Rust, cargo
│   ├── htop.sh               # C, autotools
│   ├── tmux.sh               # C, autotools
│   ├── flameshot.sh          # C++, cmake/Qt5
│   ├── opencode.sh           # Go
│   ├── ripgrep.sh            # Rust, cargo
│   ├── fd.sh                 # Rust, cargo
│   ├── fzf.sh                # Go
│   ├── jq.sh                 # C, autotools
│   ├── gh.sh                 # Go (GitHub CLI)
│   ├── lazygit.sh            # Go
│   ├── lazydocker.sh         # Go
│   ├── starship.sh           # Rust, cargo
│   ├── tailscale.sh          # Go
│   ├── docker.sh             # Go (CLI only)
│   ├── obs.sh                # C++, cmake
│   ├── telegram.sh           # C++, cmake (flatpak fallback)
│   ├── audacity.sh           # C++, cmake
│   ├── gimp.sh               # C, meson
│   ├── bitwarden.sh          # TypeScript/Electron (flatpak fallback)
│   ├── easyeffects.sh        # C++, meson/gtk4
│   ├── codex.sh              # TypeScript, npm
│   ├── gemini-cli.sh         # TypeScript, npm
│   ├── kilo-cli.sh           # TypeScript, npm
│   ├── vercel-cli.sh         # TypeScript, npm
│   ├── context-hub.sh        # JavaScript, npm
│   └── claude-code.sh        # TypeScript, npm
└── installers/
    ├── install-all.sh         # orchestrator for all installers
    ├── rustup.sh              # curl installer
    ├── nvm.sh                 # git clone
    ├── homebrew.sh            # official installer
    ├── oh-my-zsh.sh           # git clone (requires zsh)
    ├── brave.sh               # apt repo
    ├── chrome.sh              # apt repo
    ├── discord.sh             # flatpak
    ├── zoom.sh                # .deb download
    ├── cursor.sh              # AppImage
    ├── warp.sh                # apt repo
    ├── voquill.sh             # AppImage from GitHub releases
    ├── insync.sh              # apt repo
    ├── stayfree.sh            # browser extension (manual)
    └── antigravity.sh         # .deb download
```

## Configuration

Environment variables you can set before running:

| Variable | Default | Description |
|----------|---------|-------------|
| `SRC_DIR` | `~/src` | Where source repos are cloned |
| `INSTALL_PREFIX` | `/usr/local` | Where from-source builds install |
| `CLEANUP_SOURCE` | `false` | Set to `true` to delete source trees after building |
| `ANTIGRAVITY_DEB_URL` | *(empty)* | Direct .deb URL for Antigravity (requires manual download) |

## Security

- **No secrets in this repo.** The `GITHUB_MCP_PAT` token is stripped from config files and replaced with a placeholder.
- `restore-configs.sh` prompts you to enter secrets at setup time.
- `.gitignore` blocks `*.env`, `*.secret`, and `.env*` patterns.

To verify no secrets slipped in:

```bash
grep -r "github_pat_" .
```

## Prerequisites

- An Ubuntu-based Linux distro (Pop!_OS, Ubuntu 22.04+, Linux Mint, etc.)
- Internet connection
- `sudo` access

Everything else is installed by the scripts themselves.

## After setup

A few things need manual attention after the scripts finish:

```bash
sudo tailscale up          # join your Tailnet
gh auth login              # authenticate GitHub CLI
cat ~/.ssh/id_ed25519.pub  # add SSH key to GitHub
```
