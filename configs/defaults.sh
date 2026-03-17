#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Default Applications & Wallpaper"
log "═══════════════════════════════════════════════════════"

# ── Default browser ──────────────────────────────────────────────────
if is_installed brave-browser; then
  xdg-settings set default-web-browser brave-browser.desktop
  log "Default browser: Brave"
elif is_installed brave-browser-stable; then
  xdg-settings set default-web-browser brave-browser-stable.desktop
  log "Default browser: Brave"
else
  warn "Brave not installed — skipping default browser"
fi

# ── Wallpaper ────────────────────────────────────────────────────────
WALLPAPER="$HOME/Pictures/Wallpapers/mementomori.png"

if [[ ! -f "$WALLPAPER" ]]; then
  if [[ -f "$SCRIPT_DIR/wallpapers/mementomori.png" ]]; then
    mkdir -p "$HOME/Pictures/Wallpapers"
    cp "$SCRIPT_DIR/wallpapers/mementomori.png" "$WALLPAPER"
    log "Wallpaper copied to $WALLPAPER"
  else
    warn "Wallpaper not found at $WALLPAPER or in repo"
  fi
fi

if [[ -f "$WALLPAPER" ]]; then
  WALLPAPER_URI="file://$WALLPAPER"
  WALLPAPER_SET=false

  # Try Cinnamon (Linux Mint)
  if dconf write /org/cinnamon/desktop/background/picture-uri "'$WALLPAPER_URI'" 2>/dev/null; then
    log "Wallpaper set (Cinnamon)"
    WALLPAPER_SET=true
  fi

  # Try GNOME / Pop!_OS / COSMIC
  if gsettings set org.gnome.desktop.background picture-uri "$WALLPAPER_URI" 2>/dev/null; then
    gsettings set org.gnome.desktop.background picture-uri-dark "$WALLPAPER_URI" 2>/dev/null || true
    log "Wallpaper set (GNOME)"
    WALLPAPER_SET=true
  fi

  if [[ "$WALLPAPER_SET" == "false" ]]; then
    warn "Could not set wallpaper — set it manually from: $WALLPAPER"
  fi
fi
