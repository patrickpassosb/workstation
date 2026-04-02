#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Default Applications, Dark Mode & Wallpaper"
log "═══════════════════════════════════════════════════════"

# ── Default browser ──────────────────────────────────────────────────
set_default_browser() {
  local desktop_file="$1"
  # xdg-settings and xdg-mime need to run as the actual user, not root
  if [[ "$(id -u)" -eq 0 ]] && [[ -n "${SUDO_USER:-}" ]]; then
    sudo -u "$SUDO_USER" xdg-settings set default-web-browser "$desktop_file"
    sudo -u "$SUDO_USER" xdg-mime default "$desktop_file" x-scheme-handler/http
    sudo -u "$SUDO_USER" xdg-mime default "$desktop_file" x-scheme-handler/https
    sudo -u "$SUDO_USER" xdg-mime default "$desktop_file" text/html
  else
    xdg-settings set default-web-browser "$desktop_file"
    xdg-mime default "$desktop_file" x-scheme-handler/http
    xdg-mime default "$desktop_file" x-scheme-handler/https
    xdg-mime default "$desktop_file" text/html
  fi
}

if is_installed brave-browser; then
  set_default_browser brave-browser.desktop
  log "Default browser: Brave"
elif is_installed brave-browser-stable; then
  set_default_browser brave-browser-stable.desktop
  log "Default browser: Brave"
else
  warn "Brave not installed — skipping default browser"
fi

# ── Dark mode ────────────────────────────────────────────────────────
DARK_SET=false

# Helper: run dconf/gsettings as the real user when script runs via sudo
run_as_user() {
  if [[ "$(id -u)" -eq 0 ]] && [[ -n "${SUDO_USER:-}" ]]; then
    sudo -u "$SUDO_USER" env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$SUDO_USER")/bus" "$@"
  else
    "$@"
  fi
}

# Cinnamon (Linux Mint)
if run_as_user dconf list /org/cinnamon/desktop/interface/ >/dev/null 2>&1; then
  run_as_user dconf write /org/cinnamon/desktop/interface/gtk-theme "'Mint-Y-Dark'"
  run_as_user dconf write /org/cinnamon/desktop/interface/icon-theme "'Mint-Y'"
  run_as_user dconf write /org/cinnamon/desktop/interface/cursor-theme "'Bibata-Modern-Classic'"
  run_as_user dconf write /org/cinnamon/theme/name "'Mint-Y-Dark'"
  # Prefer dark mode + show icons in menus and buttons
  run_as_user dconf write /org/cinnamon/desktop/interface/gtk-overlay-scrollbars true
  run_as_user dconf write /org/x/apps/portal/color-scheme "'prefer-dark'"
  run_as_user dconf write /org/cinnamon/desktop/interface/menus-have-icons true
  run_as_user dconf write /org/cinnamon/desktop/interface/buttons-have-icons true
  log "Dark mode enabled (Cinnamon)"
  DARK_SET=true
fi

# GNOME (Ubuntu / Pop!_OS)
if command -v gsettings >/dev/null 2>&1 && run_as_user gsettings list-keys org.gnome.desktop.interface >/dev/null 2>&1; then
  run_as_user gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
  run_as_user gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
  log "Dark mode enabled (GNOME)"
  DARK_SET=true
fi

# COSMIC (Pop!_OS 24.04+)
COSMIC_THEME_DIR="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1"
if [[ -d "$(dirname "$COSMIC_THEME_DIR")" ]] || command -v cosmic-comp >/dev/null 2>&1; then
  mkdir -p "$COSMIC_THEME_DIR"
  echo '"Dark"' > "$COSMIC_THEME_DIR/is_dark"
  log "Dark mode enabled (COSMIC)"
  DARK_SET=true
fi

if [[ "$DARK_SET" == "false" ]]; then
  warn "Could not set dark mode — unsupported desktop"
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
  if run_as_user dconf write /org/cinnamon/desktop/background/picture-uri "'$WALLPAPER_URI'" 2>/dev/null; then
    log "Wallpaper set (Cinnamon)"
    WALLPAPER_SET=true
  fi

  # Try GNOME / Pop!_OS / COSMIC
  if run_as_user gsettings set org.gnome.desktop.background picture-uri "$WALLPAPER_URI" 2>/dev/null; then
    run_as_user gsettings set org.gnome.desktop.background picture-uri-dark "$WALLPAPER_URI" 2>/dev/null || true
    log "Wallpaper set (GNOME)"
    WALLPAPER_SET=true
  fi

  if [[ "$WALLPAPER_SET" == "false" ]]; then
    warn "Could not set wallpaper — set it manually from: $WALLPAPER"
  fi
fi
