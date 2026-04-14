#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Installing all tools (prebuilt)"
log "═══════════════════════════════════════════════════════"

FAILED=()
INSTALLED=()
SKIPPED=()

run_tool() {
  local name="$1"
  local script="$SCRIPT_DIR/${name}.sh"
  log "── $name ────────────────────────────────────"
  if [[ ! -f "$script" ]]; then
    warn "Script not found: $script"
    SKIPPED+=("$name")
    return
  fi
  if bash "$script"; then
    INSTALLED+=("$name")
  else
    warn "Failed: $name"
    FAILED+=("$name")
  fi
}

# Core system
for name in zsh git tmux htop jq; do
  run_tool "$name"
done

# Developer utilities
for name in bat eza delta zoxide flameshot uv bun ripgrep fd starship fzf gh docker lazygit lazydocker opencode tailscale easyeffects; do
  run_tool "$name"
done

# Heavy apps (Flatpak / deb)
for name in nodejs obs telegram audacity gimp bitwarden; do
  run_tool "$name"
done

# Node.js CLIs (need Node installed first)
log ""
log "═══════════════════════════════════════════════════════"
log "  Node.js/TS CLIs"
log "═══════════════════════════════════════════════════════"
for name in codex gemini-cli kilo-cli vercel-cli context-hub claude-code; do
  run_tool "$name"
done

log ""
log "═══════════════════════════════════════════════════════"
log "  Tools summary"
log "═══════════════════════════════════════════════════════"
log "Installed: ${INSTALLED[*]:-none}"
[[ ${#SKIPPED[@]} -gt 0 ]] && warn "Skipped: ${SKIPPED[*]}"
[[ ${#FAILED[@]} -gt 0 ]] && err "Failed: ${FAILED[*]}"

[[ ${#FAILED[@]} -eq 0 ]]
