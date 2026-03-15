#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Desktop Settings"
log "═══════════════════════════════════════════════════════"

if ! command -v gsettings >/dev/null 2>&1; then
  warn "gsettings not found — skipping desktop settings"
  exit 0
fi

set_if_available() {
  local schema="$1" key="$2" value="$3"
  if gsettings list-keys "$schema" 2>/dev/null | grep -qx "$key"; then
    gsettings set "$schema" "$key" "$value"
    log "  $schema :: $key = $value"
  else
    warn "  Key not found: $schema :: $key"
  fi
}

# ── Theme ────────────────────────────────────────────────────────────
log "Setting theme..."
set_if_available org.gnome.desktop.interface gtk-theme "'Mint-Y-Aqua'"
set_if_available org.gnome.desktop.interface icon-theme "'Mint-Y-Sand'"

# ── Touchpad / Mouse ────────────────────────────────────────────────
log "Setting input preferences..."
set_if_available org.gnome.desktop.peripherals.touchpad natural-scroll "true"

# ── Keyboard ────────────────────────────────────────────────────────
# Add more gsettings here as needed. Examples:
# set_if_available org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
# set_if_available org.gnome.desktop.interface clock-format "'24h'"

log "Desktop settings applied"
