# workstation

Automated setup scripts for Ubuntu-based Linux workstations (Pop!_OS, Ubuntu, Linux Mint, etc.).

Choose a **build level** to control how much gets compiled from source vs. installed pre-built. Every script supports three modes: `prebuilt`, `clone`, and `build`. Each script is idempotent and can run individually or as part of the full orchestrated setup.

## Quick start

```bash
git clone https://github.com/patrickpassosb/workstation.git
cd workstation
./setup.sh              # interactive level prompt
./setup.sh --level 0    # all pre-built, no compilation
./setup.sh --level 3    # compile everything from source
```

## Build levels

| Level | Name | What gets compiled | Estimated time |
|-------|------|--------------------|----------------|
| **0** | No-compile | Nothing — all pre-built (apt, flatpak, npm, GitHub releases) | ~15 min |
| **1** | Beginner | 6 small Rust/Go CLIs: ripgrep, fd, fzf, lazygit, lazydocker, opencode | ~30 min |
| **2** | Intermediate | 18 tools (Level 1 + zsh, git, tmux, htop, jq, flameshot, starship, uv, gh, tailscale, docker, easyeffects) | ~1-2 hours |
| **3** | Hard mode | All 30 tools including Node.js, OBS, GIMP, Audacity, Telegram, Bitwarden | ~3-5 hours |

### Flags

```bash
./setup.sh --level 1               # compile only small CLIs
./setup.sh --level 0 --skip-tools  # skip tool installation entirely
./setup.sh --skip-installers       # skip proprietary installers
./setup.sh --skip-configs          # skip dotfile restoration
```

## Run individual scripts

Every script is standalone and accepts a mode argument:

```bash
./tools/ripgrep.sh              # defaults to "build" (clone + compile)
./tools/ripgrep.sh prebuilt     # install pre-built binary via apt
./tools/ripgrep.sh clone        # clone source only + print build instructions
./tools/ripgrep.sh build        # clone + compile + install

./installers/brave.sh           # install Brave browser
./configs/restore-configs.sh    # restore dotfiles (backs up existing ones first)
```

## Execution phases

| Phase | What it does |
|-------|-------------|
| **0 - Preflight** | Checks internet connectivity |
| **1 - Bootstrap** | `apt update`, installs base tools (`build-essential`, `curl`, `flatpak`, etc.), creates productivity folders, installs JetBrains Mono Nerd Font |
| **2 - Toolchains** | Installs Rust toolchain (rustup) and Node.js version manager (nvm) |
| **3 - Tools** | Installs 30 tools using the selected level (prebuilt or build per tool) |
| **4 - Installers** | Installs proprietary/packaged apps (Brave, Chrome, Cursor, Warp, Discord, etc.) |
| **5 - Configs** | Restores shell configs, configures Flameshot as Print Screen, SSH key generation |
| **6 - Cleanup** | `apt autoclean`, `flatpak update`, prints summary |

## Pre-built install methods (Level 0)

| Category | Tools | Method |
|----------|-------|--------|
| apt packages | zsh, git, tmux, htop, jq, ripgrep, fd-find, fzf | `apt install` |
| Flatpak | flameshot, OBS, GIMP, Audacity, Telegram, Bitwarden, EasyEffects | `flatpak install` |
| GitHub releases | lazygit, lazydocker, opencode | Binary download |
| Official installers | tailscale, starship, uv | `curl \| sh` |
| Official apt repos | gh, docker | APT repository + `apt install` |
| npm global | codex, gemini-cli, kilo-cli, vercel-cli, context-hub, claude-code | `npm install -g` |
| nvm | Node.js | `nvm install --lts` |

## Repository structure

```
workstation/
├── setup.sh                  # main orchestrator (--level 0|1|2|3)
├── lib/
│   ├── helpers.sh            # shared functions (log, clone_or_pull, github_release_install, etc.)
│   └── registry.sh           # tool → build-level mappings + get_tool_mode()
├── configs/
│   ├── zshrc                 # sanitized .zshrc (secrets stripped)
│   ├── bashrc                # sanitized .bashrc (secrets stripped)
│   ├── gitconfig             # git config (uses gh auth, no tokens)
│   └── restore-configs.sh    # backs up existing configs, copies these, prompts for secrets
├── tools/                    # 30 tools, each with prebuilt/clone/build modes
│   ├── install-all.sh        # orchestrator — accepts level, uses registry
│   ├── ripgrep.sh            # Rust, cargo        (Level 1)
│   ├── fd.sh                 # Rust, cargo        (Level 1)
│   ├── fzf.sh                # Go                 (Level 1)
│   ├── lazygit.sh            # Go                 (Level 1)
│   ├── lazydocker.sh         # Go                 (Level 1)
│   ├── opencode.sh           # Go                 (Level 1)
│   ├── zsh.sh                # C, autotools       (Level 2)
│   ├── git.sh                # C, make            (Level 2)
│   ├── tmux.sh               # C, autotools       (Level 2)
│   ├── htop.sh               # C, autotools       (Level 2)
│   ├── jq.sh                 # C, autotools       (Level 2)
│   ├── flameshot.sh          # C++, cmake/Qt5     (Level 2)
│   ├── starship.sh           # Rust, cargo        (Level 2)
│   ├── uv.sh                 # Rust, cargo        (Level 2)
│   ├── gh.sh                 # Go (GitHub CLI)    (Level 2)
│   ├── tailscale.sh          # Go                 (Level 2)
│   ├── docker.sh             # Go (CLI only)      (Level 2)
│   ├── easyeffects.sh        # C++, meson/gtk4    (Level 2)
│   ├── nodejs.sh             # C++, configure     (Level 3)
│   ├── obs.sh                # C++, cmake         (Level 3)
│   ├── telegram.sh           # C++, cmake         (Level 3)
│   ├── audacity.sh           # C++, cmake         (Level 3)
│   ├── gimp.sh               # C, meson           (Level 3)
│   ├── bitwarden.sh          # TypeScript/Electron(Level 3)
│   ├── codex.sh              # TypeScript, npm    (Level 3)
│   ├── gemini-cli.sh         # TypeScript, npm    (Level 3)
│   ├── kilo-cli.sh           # TypeScript, npm    (Level 3)
│   ├── vercel-cli.sh         # TypeScript, npm    (Level 3)
│   ├── context-hub.sh        # JavaScript, npm    (Level 3)
│   └── claude-code.sh        # TypeScript, npm    (Level 3)
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
