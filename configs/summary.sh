#!/usr/bin/env bash
# Post-install summary: shows what's installed, what's missing, and the
# manual steps the user still has to take on a fresh PC.

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/helpers.sh
source "$SCRIPT_DIR/../lib/helpers.sh"

# List of (label, command, version_arg) tuples.
# command is run silently; version_arg is appended (e.g. --version) to extract a version.
CHECKS=(
  "zsh|zsh|--version"
  "git|git|--version"
  "tmux|tmux|-V"
  "htop|htop|--version"
  "jq|jq|--version"
  "bat|bat|--version"
  "eza|eza|--version"
  "delta|delta|--version"
  "zoxide|zoxide|--version"
  "flameshot|flameshot|--version"
  "uv|uv|--version"
  "bun|bun|--version"
  "ripgrep|rg|--version"
  "fd|fd|--version"
  "starship|starship|--version"
  "fzf|fzf|--version"
  "gh|gh|--version"
  "docker|docker|--version"
  "lazygit|lazygit|--version"
  "lazydocker|lazydocker|--version"
  "opencode|opencode|--version"
  "tailscale|tailscale|--version"
  "rustc|rustc|--version"
  "cargo|cargo|--version"
  "nvm|nvm|--version"
  "node|node|--version"
  "npm|npm|--version"
  "semgrep|semgrep|--version"
  "codeql|codeql|version"
  "nuclei-docker|nuclei-docker|--help"
  "snyk-agent-scan-safe|snyk-agent-scan-safe|--help"
  "caido|caido|--version"
  "ghidraRun|ghidraRun|"
  "aflpp-docker|aflpp-docker|--help"
  "ctx7|ctx7|--version"
  "chub|chub|--version"
  "omx|omx|--version"
  "sisyphus|sisyphus|--version"
  "codex|codex|--version"
  "claude-code|claude-code|--version"
)

log "═══════════════════════════════════════════════════════"
log "  What's installed on this machine"
log "═══════════════════════════════════════════════════════"

installed=()
missing=()

for entry in "${CHECKS[@]}"; do
  IFS='|' read -r label cmd varg <<<"$entry"
  if is_installed "$cmd"; then
    version=""
    if [[ -n "$varg" ]]; then
      version="$(
        "$cmd" "$varg" 2>/dev/null \
          | tr -d '\r' \
          | grep -oE '[0-9]+(\.[0-9]+)+([._+-][A-Za-z0-9]+)*' \
          | head -n1 \
          || true
      )"
    fi
    if [[ -n "$version" ]]; then
      printf '  \033[32m✓\033[0m  %-22s %s\n' "$label" "$version"
    else
      printf '  \033[32m✓\033[0m  %-22s installed\n' "$label"
    fi
    installed+=("$label")
  else
    printf '  \033[31m✗\033[0m  %-22s not found\n' "$label"
    missing+=("$label")
  fi
done

# Optional: Flatpak apps (only if flatpak is installed)
if command -v flatpak >/dev/null 2>&1; then
  log ""
  log "  Flatpak apps:"
  for app in org.flameshot.Flameshot com.github.wwmm.easyeffects org.telegram.desktop \
             com.bitwarden.desktop com.obsproject.Studio org.audacityteam.Audacity \
             org.gimp.GIMP org.discordapp.Discord; do
    if flatpak info "$app" >/dev/null 2>&1; then
      printf '  \033[32m✓\033[0m  %-22s\n' "$app"
    else
      printf '  \033[31m✗\033[0m  %-22s not installed\n' "$app"
    fi
  done
fi

log ""
log "  Installed: ${#installed[@]}    Missing: ${#missing[@]}"
if [[ ${#missing[@]} -gt 0 ]]; then
  warn "  Missing tools: ${missing[*]}"
fi

# Manual steps that cannot be scripted
log ""
log "═══════════════════════════════════════════════════════"
log "  Manual steps (do these once on a fresh machine)"
log "═══════════════════════════════════════════════════════"
printf '  %s\n' "1. Generate an SSH key:        ssh-keygen -t ed25519"
printf '  %s\n' "2. Authenticate GitHub:        gh auth login -p ssh -w"
printf '  %s\n' "3. Join your Tailnet:          sudo tailscale up"
printf '  %s\n' "4. Open Obsidian once to register CLI:"
printf '  %s\n' "     obsidian-app"
printf '  %s\n' "     (then Settings -> General -> CLI -> Enable)"
printf '  %s\n' "5. Re-login (or reboot) so the docker group takes effect"
