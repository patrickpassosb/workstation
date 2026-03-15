#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Phase 4: Installers (proprietary & package managers)"
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

INSTALLER_SCRIPTS=(
  oh-my-zsh
  homebrew
  brave
  chrome
  cursor
  warp
  zoom
  discord
  voquill
  insync
  antigravity
  stayfree
)

for name in "${INSTALLER_SCRIPTS[@]}"; do
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
log "  Installer summary"
log "═══════════════════════════════════════════════════════"
log "Installed: ${INSTALLED[*]:-none}"
[[ ${#SKIPPED[@]} -gt 0 ]] && warn "Skipped: ${SKIPPED[*]}"
[[ ${#FAILED[@]} -gt 0 ]] && err "Failed: ${FAILED[*]}"

[[ ${#FAILED[@]} -eq 0 ]]
