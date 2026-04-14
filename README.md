# workstation — prebuilt-only

One-command, unattended setup for Ubuntu-based Linux workstations (Pop!_OS, Ubuntu, Linux Mint, etc.). Everything is installed prebuilt (apt, Flatpak, GitHub releases, `curl | sh`, `bun`/`npm`). No phases, no levels, no prompts — just run it.

## Quick start

```bash
git clone https://github.com/patrickpassosb/workstation.git
cd workstation
./setup.sh
```

## What it does

| Step | What it does |
|------|-------------|
| **Preflight** | Checks internet connectivity |
| **Bootstrap** | `apt update`, base tools, Flathub remote, productivity folders, JetBrains Mono Nerd Font |
| **Toolchains** | Installs Rust (rustup) and Node.js (nvm + LTS) — needed by some CLIs |
| **Tools** | Installs 35 prebuilt tools (see below) |
| **Installers** | Installs proprietary apps (Brave, Chrome, Cursor, Warp, Discord, etc.) + agentic CLIs |
| **Configs** | Restores dotfiles, firewall, ClamAV, unattended upgrades, NextDNS, focus mode, npm hardening |
| **Defaults** | Sets zsh as default shell, configures terminal fonts, Flameshot on Print Screen |
| **Cleanup** | `apt autoclean`, `flatpak update` |

## Prebuilt install methods

| Category | Tools | Method |
|----------|-------|--------|
| apt packages | zsh, git, tmux, htop, jq, ripgrep, fd-find, fzf, bat, zoxide | `apt install` |
| Flatpak | flameshot, OBS, GIMP, Audacity, Telegram, Bitwarden, EasyEffects | `flatpak install` |
| GitHub releases | lazygit, lazydocker, opencode, eza, delta | Binary download |
| Official installers | tailscale, starship, uv, bun | `curl \| sh` |
| Official apt repos | gh, docker | APT repository + `apt install` |
| Node global | codex, gemini-cli, kilo-cli, vercel-cli, context-hub, claude-code | `bun install -g` (fallback to npm) |
| nvm | Node.js | `nvm install --lts` |

Node CLIs install via **bun** when available (10–20× faster than npm) and fall back to npm automatically.

## Run individual scripts

Every tool script installs the prebuilt binary when run directly:

```bash
./tools/ripgrep.sh            # apt install ripgrep
./tools/bun.sh                # curl | sh
./tools/claude-code.sh        # bun install -g @anthropic-ai/claude-code

./installers/brave.sh         # install Brave browser
./configs/restore-configs.sh  # restore dotfiles
```

## Repository structure

```
workstation/
├── setup.sh                  # main orchestrator — run this
├── lib/
│   └── helpers.sh            # shared bash helpers (incl. bun_or_npm_install*)
├── tools/                    # 35 prebuilt tool installers
│   ├── install-all.sh        # runs every tool
│   └── *.sh                  # one per tool
├── installers/               # proprietary apps + toolchains + agentic tools
│   ├── install-all.sh
│   ├── agent-tools.sh
│   ├── rustup.sh / nvm.sh
│   └── brave.sh / chrome.sh / cursor.sh / warp.sh / ...
└── configs/                  # dotfiles, security, defaults
    ├── zshrc / bashrc / gitconfig / starship.toml
    ├── firewall.sh / clamav.sh / dns-nextdns.sh / focus-mode.sh
    ├── npm-security.sh / unattended-upgrades.sh
    └── restore-configs.sh
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SRC_DIR` | `~/src` | Where source repos are cloned (unused on this branch — kept for helper compatibility) |
| `INSTALL_PREFIX` | `/usr/local` | Install target for GitHub-release binaries |
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
ssh-keygen -t ed25519       # generate SSH key (not done automatically)
gh auth login -p ssh -w     # authenticate GitHub CLI (not done automatically)
sudo tailscale up           # join your Tailnet
```

## Other branches

The `master` branch has the full phase/level system (compile from source at Level 1–10) for learning how tools are built. This branch strips all of that for a fast, unattended install.
