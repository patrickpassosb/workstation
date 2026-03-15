#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Phase 3: From-source (clone repos only)"
log "═══════════════════════════════════════════════════════"

FAILED=()
SKIPPED=()
CLONED=()

run_script() {
  local script="$1"
  local name
  name="$(basename "$script" .sh)"
  log "── $name ──────────────────────────────────────────"
  if bash "$script"; then
    CLONED+=("$name")
  else
    warn "Failed: $name"
    FAILED+=("$name")
  fi
}

# Phase 3a: Core tools (order matters for dependencies)
SCRIPTS=(
  zsh
  git
  tmux
  htop
  jq
  flameshot
  uv
  ripgrep
  fd
  starship
  nodejs
  opencode
  fzf
  gh
  lazygit
  lazydocker
  tailscale
  docker
  obs
  telegram
  audacity
  gimp
  bitwarden
  easyeffects
)

for name in "${SCRIPTS[@]}"; do
  script="$SCRIPT_DIR/${name}.sh"
  if [[ -f "$script" ]]; then
    run_script "$script"
  else
    warn "Script not found: $script"
    SKIPPED+=("$name")
  fi
done

# Phase 3b: Node.js/TypeScript CLIs
log ""
log "═══════════════════════════════════════════════════════"
log "  Phase 3b: From-source (Node.js/TS CLIs - clone only)"
log "═══════════════════════════════════════════════════════"

TS_SCRIPTS=(
  codex
  gemini-cli
  kilo-cli
  vercel-cli
  context-hub
  claude-code
)

for name in "${TS_SCRIPTS[@]}"; do
  script="$SCRIPT_DIR/${name}.sh"
  if [[ -f "$script" ]]; then
    run_script "$script"
  else
    warn "Script not found: $script"
    SKIPPED+=("$name")
  fi
done

# Summary
log ""
log "═══════════════════════════════════════════════════════"
log "  From-source clone summary"
log "═══════════════════════════════════════════════════════"
log "Cloned: ${CLONED[*]:-none}"
[[ ${#SKIPPED[@]} -gt 0 ]] && warn "Skipped: ${SKIPPED[*]}"
[[ ${#FAILED[@]} -gt 0 ]] && err "Failed: ${FAILED[*]}"
log ""
log "All sources are in: ${SRC_DIR:-$HOME/src}"
log "Build instructions were printed for each tool above."
log "You can compile them individually at your own pace."

[[ ${#FAILED[@]} -eq 0 ]]
