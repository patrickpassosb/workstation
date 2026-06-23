# workstation — prebuilt-only

One-command, unattended setup for Linux workstations. Ubuntu-like distros remain supported (Pop!_OS, Ubuntu, Linux Mint, etc.) and Fedora KDE is now a first-class target. Everything is installed prebuilt (`apt`/`dnf`, Flatpak, GitHub releases, `curl | sh`, `bun`/`npm`). No phases, no levels, no prompts — just run it.

## Quick start

```bash
git clone https://github.com/patrickpassosb/workstation.git
cd workstation
./setup.sh
```

The full install takes ~5-10 min depending on network. To skip the security lab
(Nuclei, Semgrep, CodeQL, Snyk, Ghidra, AFL++, MCPs, etc.) — useful for re-runs
on an already-set-up machine — pass `--skip-security-lab`.

```bash
./setup.sh --skip-security-lab
```

## What it does

| Step | What it does |
|------|-------------|
| **Preflight** | Checks internet connectivity |
| **Bootstrap** | Distro package refresh, base tools, Flathub remote, productivity folders, JetBrains Mono Nerd Font |
| **Toolchains** | Installs Rust (rustup) and Node.js (nvm + LTS) — needed by some CLIs |
| **Tools** | Installs the prebuilt CLI/app stack, Obsidian, and the security lab tools (see below) |
| **Installers** | Installs proprietary apps (Brave, Chrome, Warp, Discord, etc.) + agentic CLIs |
| **Configs** | Restores dotfiles, clones/configures the Obsidian vault, firewall, ClamAV, automatic security updates, NextDNS, focus mode, npm hardening |
| **Defaults** | Sets zsh as default shell, configures terminal fonts, Flameshot on Print Screen |
| **Cleanup** | Package manager cleanup, `flatpak update` |

## Prebuilt install methods

| Category | Tools | Method |
|----------|-------|--------|
| apt/dnf packages | zsh, git, tmux, htop, jq, ripgrep, fd-find, fzf, bat, zoxide | `apt install` / `dnf install` |
| Flatpak | flameshot, OBS, GIMP, Audacity, Telegram, Bitwarden, EasyEffects, Fedora Brave/Zoom | `flatpak install` |
| GitHub releases | lazygit, lazydocker, opencode, eza, delta | Binary download |
| AppImage | Obsidian | GitHub release AppImage + desktop/URI handler |
| Official installers | tailscale, starship, uv, bun | `curl \| sh` |
| Official distro repos | gh, docker, Chrome | APT/DNF repository + package install |
| Node global | codex, gemini-cli, kilo-cli, vercel-cli, context-hub, claude-code | `bun install -g` (fallback to npm) |
| nvm | Node.js | `nvm install --lts` |
| Security tools | Semgrep, CodeQL, Nuclei, Snyk Agent Scan, Ghidra MCP, AFL++ MCP, OSS-Fuzz-Gen | Host install where useful; Docker/uv wrappers where safer |

Node CLIs install via **bun** when available (10–20× faster than npm) and fall back to npm automatically.

## Run individual scripts

Every tool script installs the prebuilt binary when run directly:

```bash
./tools/ripgrep.sh            # apt install ripgrep
./tools/bun.sh                # curl | sh
./tools/claude-code.sh        # bun install -g @anthropic-ai/claude-code
./tools/obsidian.sh           # install Obsidian AppImage
./configs/obsidian-vault.sh   # clone/update the Obsidian vault and enable CLI config
./tools/nuclei.sh             # install isolated nuclei-docker wrapper

./installers/brave.sh         # install Brave browser
./configs/restore-configs.sh  # restore dotfiles
```

## Repository structure

```
workstation/
├── setup.sh                       # main orchestrator — run this
├── fix-sources.sh                 # patches stale distro codenames in third-party apt sources
├── lib/
│   └── helpers.sh                 # shared bash helpers (apt/dnf dispatch, Docker wrappers, etc.)
├── tools/                         # prebuilt tool installers (one per tool)
│   ├── install-all.sh             # runs every tool
│   ├── codex.sh, claude-code.sh, opencode.sh, kilo-cli.sh, vercel-cli.sh, context-hub.sh
│   ├── lazygit.sh, lazydocker.sh, eza.sh, delta.sh, bat.sh, fd.sh, ripgrep.sh, fzf.sh
│   ├── zsh.sh, git.sh, tmux.sh, htop.sh, jq.sh, starship.sh, zoxide.sh
│   ├── bun.sh, uv.sh, nodejs.sh
│   ├── docker.sh, gh.sh, tailscale.sh
│   ├── flameshot.sh, easyeffects.sh, obs.sh, telegram.sh, audacity.sh, gimp.sh, bitwarden.sh
│   └── security lab: security-lab.sh, semgrep.sh, codeql.sh, nuclei.sh, snyk-agent-scan.sh,
│       caido.sh, burp.sh, ghidra.sh, aflpp.sh, obsidian.sh, oss-fuzz-gen.sh
├── installers/                    # proprietary apps + toolchains + agentic CLIs
│   ├── install-all.sh
│   ├── agent-tools.sh             # ctx7, chub, omx, omc (bun install -g)
│   ├── rustup.sh, nvm.sh, oh-my-zsh.sh, homebrew.sh
│   └── brave.sh, chrome.sh, warp.sh, zoom.sh, discord.sh, voquill.sh, antigravity-cli.sh, trae.sh, stayfree.sh
├── configs/                       # dotfiles + system hardening + defaults
│   ├── zshrc, bashrc, gitconfig, starship.toml
│   ├── restore-configs.sh
│   ├── defaults.sh                # default browser, dark mode, wallpaper
│   ├── ide-extensions.sh          # VS Code extension set
│   ├── browser-extensions.sh      # Brave / Chrome managed extension policy
│   ├── startup-apps.sh            # autostart .desktop files
│   ├── obsidian-vault.sh          # clones & registers the Obsidian vault
│   ├── sync-skills.sh, centralize-skills.sh, lab-mcp-consent.sh, lab-mcps.json
│   ├── summary.sh                 # post-install ✓/✗ report
│   ├── firewall.sh, clamav.sh, dns-nextdns.sh, focus-mode.sh
│   ├── npm-security.sh, unattended-upgrades.sh
│   └── wallpapers/                # default wallpaper assets
├── prompts/
│   └── implement.md               # legacy Ralph loop task runner
├── skills/                        # local agent skills (sync'd to ~/.agents/skills)
└── docs/
    └── security-lab.md            # lab operator notes
```

### Versioning policy

This script always installs the latest version of every tool:

- **apt / dnf packages** (zsh, git, tmux, jq, htop, bat, fd, fzf, ripgrep, gh, docker, etc.) — the distro repo's current version, refreshed on every run.
- **Flatpak apps** (flameshot, OBS, GIMP, Audacity, Telegram, Bitwarden, EasyEffects) — the current Flathub release.
- **GitHub-release binaries** (lazygit, lazydocker, eza, obsidian) — `github_latest_tag` is queried at install time.
- **Official curl-piped installers** (bun, uv, starship, zoxide, rustup, tailscale, oh-my-zsh) — upstream's `latest` (or the latest tagged release).
- **Node global CLIs** (claude-code, codex, opencode, kilo-cli, vercel-cli, context-hub, ctx7, chub, omx, omc) — `@latest` from the npm registry, installed via bun (or npm fallback).

## Obsidian

The setup installs Obsidian as an AppImage, registers the `obsidian://` URI handler, enables the Obsidian CLI flag in `~/.config/obsidian/obsidian.json`, and clones your actual Obsidian vault:

```text
~/Documents/Obsidian Vault
https://github.com/patrickpassosb/obsidian-vault.git
```

The CLI binary itself is registered by Obsidian after first launch from Settings -> General. If the script warns that `obsidian` is not in PATH, open Obsidian once and enable/install the CLI there.

## Security lab

The security stack follows the research doc with isolation where practical:

- Host tools: `semgrep`, `codeql`, existing `ghidraRun` linkage.
- Docker wrappers: `nuclei-docker`, `aflpp-docker`.
- Cautious runner: `snyk-agent-scan-safe`.
- Proxy workspaces: `~/hacking/proxy/caido` and `~/hacking/proxy/burp`.
- MCP repos: `~/hacking/tools/ghidra-mcp`, `~/hacking/tools/aflpp-mcp`, `~/hacking/tools/oss-fuzz-gen`.

See `docs/security-lab.md` for the quick operator notes.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SRC_DIR` | `~/src` | Where source repos are cloned (unused on this branch — kept for helper compatibility) |
| `INSTALL_PREFIX` | `/usr/local` | Install target for GitHub-release binaries |
| `WORKSTATION_DISTRO_OVERRIDE` | *(empty)* | Optional test override: `ubuntu` or `fedora` |
| `OBSIDIAN_VAULT_REPO` | `https://github.com/patrickpassosb/obsidian-vault.git` | Vault repo to clone/update |
| `OBSIDIAN_VAULT_DIR` | `~/Documents/Obsidian Vault` | Local Obsidian vault path |
| `SECURITY_LAB_DIR` | `~/hacking` | Security lab root |

## Security

- **No secrets in this repo.** Config files have tokens stripped and replaced with placeholders.
- `restore-configs.sh` prompts you to enter secrets at setup time.
- `.gitignore` blocks `*.env`, `*.secret`, and `.env*` patterns.

## Prerequisites

- Ubuntu-like Linux distro (Pop!_OS, Ubuntu 22.04+, Linux Mint, etc.) or Fedora KDE
- Internet connection
- `sudo` access

## Fedora notes

- Fedora uses `dnf`, `firewalld`, and `dnf-automatic` instead of `apt`, UFW, and unattended-upgrades.
- Fedora proprietary apps prefer Flatpak or direct .rpm where the vendor publishes one (Brave, Zoom, Warp, Voquill, Trae, Antigravity CLI). Only configs that touch apt sources (e.g. `fix-sources.sh`) remain apt-only.
- KDE dark mode and wallpaper are applied through Plasma command-line tools when they are available. Flameshot's Print Screen shortcut still needs a manual KDE shortcut binding if the script warns.

## After setup

`setup.sh` ends by printing a `What's installed` summary showing every tool the
script knows about with a green ✓ (and a version) or red ✗ (missing), plus the
manual steps. On a freshly installed machine the manual steps are:

```bash
ssh-keygen -t ed25519       # generate SSH key (not done automatically)
gh auth login -p ssh -w     # authenticate GitHub CLI (not done automatically)
sudo tailscale up           # join your Tailnet
obsidian-app                # open Obsidian once, enable CLI in Settings -> General
```

After `setup.sh` finishes you also need to **re-login (or reboot)** so the
`docker` group assignment takes effect.

## Other branches

The `master` branch has the full phase/level system (compile from source at Level 1–10) for learning how tools are built. This branch strips all of that for a fast, unattended install.
