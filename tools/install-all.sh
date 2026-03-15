#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"
source "$SCRIPT_DIR/../lib/registry.sh"

LEVEL="${1:-0}"

LEVEL_NAMES=(
  "No-compile (all pre-built)"
  "Beginner (6 small Rust/Go CLIs)"
  "Intermediate (18 tools)"
  "Hard mode (all 30 tools from source)"
)

log "═══════════════════════════════════════════════════════"
log "  Phase 3: Tools — Level $LEVEL: ${LEVEL_NAMES[$LEVEL]}"
log "═══════════════════════════════════════════════════════"

FAILED=()
SKIPPED=()
INSTALLED=()

run_tool() {
  local name="$1"
  local mode
  mode="$(get_tool_mode "$name" "$LEVEL")"
  local script="$SCRIPT_DIR/${name}.sh"

  log "── $name ($mode) ────────────────────────────────────"
  if [[ ! -f "$script" ]]; then
    warn "Script not found: $script"
    SKIPPED+=("$name")
    return
  fi
  if bash "$script" "$mode"; then
    INSTALLED+=("$name")
  else
    warn "Failed: $name"
    FAILED+=("$name")
  fi
}

# ── Phase 3a: Core system tools ──────────────────────────────────────
for name in zsh git tmux htop jq; do
  run_tool "$name"
done

# ── Phase 3b: Developer utilities ────────────────────────────────────
for name in flameshot uv ripgrep fd starship fzf gh lazygit lazydocker opencode tailscale docker easyeffects; do
  run_tool "$name"
done

# ── Phase 3c: Heavy apps ─────────────────────────────────────────────
for name in nodejs obs telegram audacity gimp bitwarden; do
  run_tool "$name"
done

# ── Phase 3d: Node.js CLIs (need Node installed first) ───────────────
log ""
log "═══════════════════════════════════════════════════════"
log "  Phase 3d: Node.js/TS CLIs"
log "═══════════════════════════════════════════════════════"

for name in codex gemini-cli kilo-cli vercel-cli context-hub claude-code; do
  run_tool "$name"
done

# ── Summary ──────────────────────────────────────────────────────────
log ""
log "═══════════════════════════════════════════════════════"
log "  Tools summary (Level $LEVEL)"
log "═══════════════════════════════════════════════════════"
log "Installed: ${INSTALLED[*]:-none}"
[[ ${#SKIPPED[@]} -gt 0 ]] && warn "Skipped: ${SKIPPED[*]}"
[[ ${#FAILED[@]} -gt 0 ]] && err "Failed: ${FAILED[*]}"

[[ ${#FAILED[@]} -eq 0 ]]
