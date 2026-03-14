#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Phase 3: From-source builds (compiled)"
log "═══════════════════════════════════════════════════════"

FAILED=()
SKIPPED=()
INSTALLED=()

run_script() {
  local script="$1"
  local name
  name="$(basename "$script" .sh)"
  log "── $name ──────────────────────────────────────────"
  if bash "$script"; then
    INSTALLED+=("$name")
  else
    warn "Failed: $name"
    FAILED+=("$name")
  fi
}

# Phase 3a: Compiled tools (order matters for dependencies)
COMPILED_SCRIPTS=(
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

for name in "${COMPILED_SCRIPTS[@]}"; do
  script="$SCRIPT_DIR/${name}.sh"
  if [[ -f "$script" ]]; then
    run_script "$script"
  else
    warn "Script not found: $script"
    SKIPPED+=("$name")
  fi
done

# Phase 3b: Node.js/TypeScript CLIs (require Node from Phase 3a)
log ""
log "═══════════════════════════════════════════════════════"
log "  Phase 3b: From-source builds (Node.js/TS CLIs)"
log "═══════════════════════════════════════════════════════"

if ! is_installed node; then
  warn "Node.js not found — skipping TypeScript CLI builds"
  SKIPPED+=(codex gemini-cli kilo-cli vercel-cli context-hub claude-code)
else
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
fi

# Summary
log ""
log "═══════════════════════════════════════════════════════"
log "  From-source build summary"
log "═══════════════════════════════════════════════════════"
log "Installed: ${INSTALLED[*]:-none}"
[[ ${#SKIPPED[@]} -gt 0 ]] && warn "Skipped: ${SKIPPED[*]}"
[[ ${#FAILED[@]} -gt 0 ]] && err "Failed: ${FAILED[*]}"

[[ ${#FAILED[@]} -eq 0 ]]
