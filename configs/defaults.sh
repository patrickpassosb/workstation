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
  # Copy from repo if it exists there
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

  # Detect desktop environment and set wallpaper
  DESKTOP="${XDG_CURRENT_DESKTOP:-unknown}"
  case "$DESKTOP" in
    *Cinnamon*|*X-Cinnamon*)
      dconf write /org/cinnamon/desktop/background/picture-uri "'$WALLPAPER_URI'"
      log "Wallpaper set (Cinnamon)"
      ;;
    *GNOME*|*ubuntu*|*pop*|*COSMIC*)
      gsettings set org.gnome.desktop.background picture-uri "$WALLPAPER_URI"
      gsettings set org.gnome.desktop.background picture-uri-dark "$WALLPAPER_URI" 2>/dev/null || true
      log "Wallpaper set (GNOME)"
      ;;
    *KDE*|*Plasma*)
      warn "KDE wallpaper must be set manually — file is at $WALLPAPER"
      ;;
    *)
      # Try both, ignore failures
      dconf write /org/cinnamon/desktop/background/picture-uri "'$WALLPAPER_URI'" 2>/dev/null \
        || gsettings set org.gnome.desktop.background picture-uri "$WALLPAPER_URI" 2>/dev/null \
        || warn "Could not detect desktop environment ($DESKTOP) — set wallpaper manually: $WALLPAPER"
      log "Wallpaper set (auto-detected)"
      ;;
  esac
fi
