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

`./setup.sh` aborts if you pass an unknown flag (a typo'd `--skip-secuity-lab`
no longer silently installs the whole security lab). Two concurrent runs on
the same user account are blocked by an advisory `flock` on
`~/.workstation-setup.lock`.

## What it does

| Step | What it does |
|------|-------------|
| **Preflight** | Checks internet connectivity, `sudo`, `curl`, and the distro package manager |
| **Bootstrap** | Distro package refresh, base tools, Flathub remote, productivity folders (`~/TEMP`, `~/AppImage`, `~/Videos/OBS Rec`, `~/GitHub/{forks,learning,work}`), Nautilus bookmarks, JetBrains Mono Nerd Font |
| **Toolchains** | Installs Rust (rustup) and Node.js (nvm + LTS) — needed by some CLIs |
| **Tools** | Installs the prebuilt CLI/app stack, Obsidian, and the security lab tools (see below) |
| **Installers** | Installs proprietary apps (Brave, Chrome, Warp, Discord, etc.) + agentic CLIs + npm postinstall allowlist |
| **Configs** | Restores dotfiles, clones/configures the Obsidian vault, syncs agent skills to every CLI, IDE/browser extensions, default apps/wallpaper, startup apps |
| **Security hardening** | Firewall, ClamAV, automatic security upgrades, NextDNS, focus mode, npm postinstall lockdown. **Failures here abort `setup.sh`** (a silent hardening failure is a security posture regression). |
| **Defaults** | Sets zsh as default shell, configures terminal fonts, Flameshot on Print Screen |
| **Cleanup** | Package manager cleanup, `flatpak update` |

## Prebuilt install methods

| Category | Tools | Method |
|----------|-------|--------|
| apt/dnf packages | zsh, git, tmux, htop, jq, ripgrep, fzf, bat | `apt install` / `dnf install` |
| Flatpak | flameshot, OBS, GIMP, Audacity, Telegram, Bitwarden, EasyEffects, Zoom (Fedora) | `flatpak install` |
| GitHub releases | lazygit, lazydocker, eza, delta, obsidian | Binary download (`github_release_install` helper) |
| AppImage | Obsidian | GitHub release AppImage + desktop/URI handler |
| Official installers | tailscale, starship, uv, bun, rustup, oh-my-zsh, homebrew, antigravity-cli | `curl \| sh` via `run_installer_script` (download-then-exec, optional SHA256 verification) |
| Official distro repos | gh, docker, Chrome | APT/DNF repository + package install (modern `signed-by=` keyring) |
| Node global | codex, opencode, kilo-cli, vercel-cli, context-hub, claude-code | `bun install -g` (fallback to npm), pinned via `*_VERSION` env vars in `installers/agent-tools.sh` |
| nvm | Node.js | `nvm install --lts` |
| Security tools | Semgrep, CodeQL, Nuclei, Snyk Agent Scan, Ghidra MCP, AFL++ MCP, OSS-Fuzz-Gen | Host install where useful; Docker/uv wrappers where safer |

Node CLIs install via **bun** when available (10–20× faster than npm) and fall back to npm automatically. The 5 thin Node-CLI wrapper scripts were collapsed into a data-driven loop in `tools/install-all.sh`.

## Run individual scripts

Most tool installers can be run directly:

```bash
./tools/bun.sh                # curl|sh (now download-then-exec via run_installer_script)
./tools/obsidian.sh           # install Obsidian AppImage
./tools/nuclei.sh             # install isolated nuclei-docker wrapper
./configs/obsidian-vault.sh   # clone/update the Obsidian vault and enable CLI config
./installers/brave.sh         # install Brave browser
./configs/restore-configs.sh  # restore dotfiles
```

The pure one-liner tools (zsh, git, tmux, htop, jq, ripgrep, fzf, obs, telegram, audacity, gimp, bitwarden, easyeffects, flameshot) are installed inline by `tools/install-all.sh` — they no longer have separate wrapper scripts.

## Repository structure

```
workstation/
├── setup.sh                       # main orchestrator — run this
├── fix-sources.sh                 # patches stale distro codenames in third-party apt sources
├── lib/
│   └── helpers.sh                 # shared bash helpers (apt/dnf dispatch, safe_curl,
│                                  # download_and_verify, run_installer_script,
│                                  # github_release_install, Docker wrappers, etc.)
├── tools/                         # prebuilt tool installers (one per non-trivial tool)
│   ├── install-all.sh             # runs every tool; data-driven loops for one-liners
│   │                              # (apt: zsh/git/tmux/htop/jq/fzf/ripgrep;
│   │                              #  Flatpak: obs/telegram/audacity/gimp/bitwarden;
│   │                              #  Node CLIs: codex/kilo-cli/vercel-cli/
│   │                              #  context-hub/claude-code)
│   ├── bat.sh, fd.sh              # distro-specific binary-name fallbacks (batcat, fdfind)
│   ├── bun.sh, uv.sh, starship.sh, tailscale.sh, zoxide.sh
│   ├── lazygit.sh, lazydocker.sh, eza.sh, delta.sh
│   ├── nodejs.sh, docker.sh, gh.sh
│   ├── obsidian.sh                # AppImage + URI handler
│   ├── opencode.sh                # Node CLI with postinstall logic
│   ├── security-lab.sh           # ~/hacking scaffolding + lab-none Docker network
│   └── security lab: semgrep.sh, codeql.sh, nuclei.sh, snyk-agent-scan.sh,
│       caido.sh, burp.sh, ghidra.sh, aflpp.sh, oss-fuzz-gen.sh
├── installers/                    # proprietary apps + toolchains + agentic CLIs
│   ├── install-all.sh
│   ├── agent-tools.sh             # ctx7, chub, omx, sisyphus (pinned via *_VERSION env vars)
│   ├── rustup.sh, nvm.sh, oh-my-zsh.sh, homebrew.sh
│   └── brave.sh, chrome.sh, warp.sh, zoom.sh, discord.sh, voquill.sh,
│       antigravity-cli.sh, trae.sh, stayfree.sh
├── configs/                       # dotfiles + system hardening + defaults
│   ├── zshrc, bashrc, gitconfig, starship.toml
│   ├── restore-configs.sh         # backs up + restores dotfiles (placeholders only — no secret prompts)
│   ├── defaults.sh                # default browser, dark mode, wallpaper
│   ├── ide-extensions.sh          # VS Code extension set
│   ├── browser-extensions.sh      # Brave / Chrome managed extension policy
│   ├── startup-apps.sh            # autostart .desktop files
│   ├── obsidian-vault.sh          # clones & registers the Obsidian vault
│   ├── sync-skills.sh, centralize-skills.sh, lab-mcp-consent.sh, lab-mcps.json
│   ├── npm-security.sh            # sets ignore-scripts=true globally
│   ├── npm-postinstall-allowlist.sh  # re-runs trusted postinstalls before lockdown
│   ├── summary.sh                 # post-install ✓/✗ report
│   ├── firewall.sh, clamav.sh, dns-nextdns.sh, focus-mode.sh
│   └── unattended-upgrades.sh
│   └── wallpapers/                # default wallpaper assets
├── prompts/
│   └── implement.md               # default Ralph loop runner prompt (referenced by
│                                  # skills/ralph-implement and skills/ralph-loop)
├── skills/                        # local agent skills (sync'd to ~/.agents/skills by
│                                  # centralize-skills.sh and to
│                                  # ~/.{claude,config/opencode,gemini,kilocode}/skills
│                                  # by sync-skills.sh). CTF skills come from the
│                                  # separate security-lab repo, not here.
└── docs/
    ├── security-lab.md            # lab operator notes (LAB_RELAXED=1, SNYK_TOKEN, image pinning)
    └── archive/                   # one-time planning/report artifacts (not regenerated)
        ├── installed-apps.html
        └── security-lab-plan.html
```

### Versioning policy

This script installs the **latest** version of every tool by default:

- **apt / dnf packages** — the distro repo's current version, refreshed on every run.
- **Flatpak apps** — the current Flathub release.
- **GitHub-release binaries** (lazygit, lazydocker, eza, obsidian) — `github_latest_tag` is queried at install time. `lazygit` and `lazydocker` fall back to a pinned tag if the GitHub API is rate-limited (set `GITHUB_TOKEN` to lift the 60/hr unauthenticated limit).
- **delta** is the one exception — `tools/delta.sh` pins `VERSION=0.18.2` for its GitHub `.deb`/tarball fallback paths (only used when the `git-delta` apt package is unavailable). Bump `VERSION` there to upgrade the fallback.
- **Official curl-piped installers** (bun, uv, starship, tailscale, rustup, oh-my-zsh, homebrew, antigravity-cli) — upstream's `latest`. Each accepts a `${PKG}_INSTALLER_SHA256` env var for full verification; without it the script is still downloaded-then-executed (never piped straight to a shell). `zoxide` is pinned to release tag `v0.9.7` (override with `ZOXIDE_VERSION`) — it is NOT pulled from `main`.
- **Node global CLIs** (codex, opencode, kilo-cli, vercel-cli, context-hub, claude-code) — npm registry's latest (no version pin by default). `installers/agent-tools.sh` exposes `CTX7_VERSION`, `CHUB_VERSION`, `OMX_VERSION`, `OMC_VERSION` so you can pin to a specific version after reviewing the package's postinstall scripts.
- **Third-party MCP repos** (ghidra-mcp, aflpp-mcp) — default to `HEAD` of their default branch, but log the resolved commit SHA so you can pin it via `GHIDRA_MCP_COMMIT` / `AFLPP_MCP_COMMIT` on the next run. `oss-fuzz-gen` is from Google's first-party repo.
- **Docker images** for the security lab (nuclei, aflpp) — default to mutable `:latest` tags, but log the resolved digest so you can pin it via `NUCLEI_DOCKER_IMAGE='image@sha256:...'` / `AFLPP_DOCKER_IMAGE='image@sha256:...'`.

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

See `docs/security-lab.md` for the quick operator notes, including `LAB_RELAXED=1` (egress opt-in), `SNYK_TOKEN`, MCP commit pinning, and Docker image digest pinning.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `INSTALL_PREFIX` | `/usr/local` | Install target for GitHub-release binaries |
| `WORKSTATION_DISTRO_OVERRIDE` | *(empty)* | Optional test override: `ubuntu` or `fedora` |
| `OBSIDIAN_VAULT_REPO` | `https://github.com/patrickpassosb/obsidian-vault.git` | Vault repo to clone/update |
| `OBSIDIAN_VAULT_DIR` | `~/Documents/Obsidian Vault` | Local Obsidian vault path |
| `OBSIDIAN_VAULT_ID` | `f44ad3882fd559bb` | Obsidian vault id for `obsidian.json` |
| `OBSIDIAN_APP_DIR` | `~/AppImage` | Where the Obsidian AppImage is stored |
| `OBSIDIAN_VERSION` | *(latest GitHub tag)* | Pinned Obsidian release tag |
| `SECURITY_LAB_DIR` | `~/hacking` | Security lab root |
| `SECURITY_TOOLS_DIR` | `$SECURITY_LAB_DIR/tools` | Where MCP repos are cloned |
| `LAB_RELAXED` | `0` | Set to `1` to let security-lab Docker wrappers use host network (egress on) |
| `NEXTDNS_ID` | `ab1bb7` | NextDNS profile id (author's public profile) |
| `GHIDRA_MCP_REPO` / `GHIDRA_MCP_DIR` / `GHIDRA_MCP_COMMIT` | bethington/ghidra-mcp / `$SECURITY_TOOLS_DIR/ghidra-mcp` / *(empty)* | Third-party Ghidra MCP repo, install path, and pinned commit |
| `AFLPP_MCP_REPO` / `AFLPP_MCP_DIR` / `AFLPP_MCP_COMMIT` | kevin-valerio/aflpp-mcp / `$SECURITY_TOOLS_DIR/aflpp-mcp` / *(empty)* | Third-party AFL++ MCP repo, install path, and pinned commit |
| `AFLPP_DOCKER_IMAGE` | `aflplusplus/aflplusplus:latest` | AFL++ Docker image (pin to `image@sha256:...` for reproducibility) |
| `NUCLEI_DOCKER_IMAGE` | `projectdiscovery/nuclei:latest` | Nuclei Docker image (pin to `image@sha256:...` for reproducibility) |
| `OSS_FUZZ_GEN_REPO` / `OSS_FUZZ_GEN_DIR` | google/oss-fuzz-gen / `$SECURITY_TOOLS_DIR/oss-fuzz-gen` | First-party OSS-Fuzz-Gen repo + path |
| `CODEQL_DIR` | `~/.local/codeql` | Where the CodeQL bundle is extracted |
| `CTX7_VERSION` / `CHUB_VERSION` / `OMX_VERSION` / `OMC_VERSION` | `latest` | Pinned versions for the agentic CLIs in `agent-tools.sh` |
| `NF_TAG` / `NF_SHA256` | `v3.3.0` / *(empty)* | Nerd Fonts release tag + optional SHA256 for the JetBrains Mono font zip |
| `${PKG}_INSTALLER_SHA256` | *(empty)* | Per-installer SHA256 verification (BUN_INSTALLER_SHA256, STARSHIP_INSTALLER_SHA256, TAILSCALE_INSTALLER_SHA256, UV_INSTALLER_SHA256, ZOXIDE_INSTALLER_SHA256, ANTIGRAVITY_INSTALLER_SHA256, HOMEBREW_INSTALLER_SHA256, OHMYZSH_INSTALLER_SHA256, RUSTUP_INSTALLER_SHA256) |
| `GITHUB_TOKEN` / `GH_TOKEN` | *(empty)* | Optional GitHub auth token to lift the 60/hr unauthenticated API rate limit (used by `github_latest_tag`) |

## Security

- **No secrets in this repo.** Config files ship with placeholders
  (e.g. `# export GITHUB_MCP_PAT=<YOUR_TOKEN_HERE>`). Fill them in
  manually after setup — `restore-configs.sh` does not prompt for
  secrets; it backs up your existing dotfiles and copies the repo's
  sanitized versions over them.
- `.gitignore` blocks `*.env`, `*.secret`, `.env*`, `*.pem`, `*.key`,
  `*.keystore`, `*.keytab`, `*.kdbx`, `*.p12`, `*.pfx`, `*.gpg`, `*.asc`,
  `id_rsa*`, `id_ed25519*`, `id_ecdsa*`, `id_dsa*`, `.netrc`, `.npmrc`,
  `.pypirc`, `.aws/`, `secrets/`, `.secret`, `secrets.{json,yaml,toml}`.
- Two scripts (`focus-mode.sh`, `dns-nextdns.sh`) set the immutable
  bit on system files via `chattr +i`. The undo command
  (`sudo chattr -i <file>`) is printed at the end of each.

## Prerequisites

- Ubuntu-like Linux distro (Pop!_OS, Ubuntu 22.04+, Linux Mint, etc.) or Fedora KDE
- Internet connection
- `sudo` access

## Fedora notes

- Fedora uses `dnf`, `firewalld`, and `dnf-automatic` instead of apt, UFW, and unattended-upgrades.
- Fedora proprietary apps prefer Flatpak or direct .rpm where the vendor publishes one (Zoom via Flatpak; Brave, Warp, Voquill, Trae, Discord via .rpm). `antigravity-cli.sh` is a `curl|sh` installer (not Flatpak or .rpm) — it's listed here for completeness. Chrome uses Google's RPM repo.
- Only `fix-sources.sh` (which touches apt sources) is apt-only; it no-ops on Fedora.
- KDE dark mode and wallpaper are applied through Plasma command-line tools when they are available. Flameshot's Print Screen shortcut still needs a manual KDE shortcut binding if the script warns.

## After setup

`setup.sh` ends by printing a `What's installed` summary showing every tool the script knows about with a green ✓ (and a version) or red ✗ (missing), plus the manual steps. On a freshly installed machine the manual steps are:

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