#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

INSTALL_PATH="$HOME/.local/bin/voquill.AppImage"

if [[ -f "$INSTALL_PATH" ]] || is_installed voquill; then
  log "Voquill is already installed."
  exit 0
fi

log "Installing Voquill..."

# Fetch latest release info from GitHub
RELEASE_JSON="$(curl -fsSL https://api.github.com/repos/jackbrumley/voquill/releases/latest)"

# Extract the AppImage download URL for linux-x64
APPIMAGE_URL="$(echo "$RELEASE_JSON" | grep -oP '"browser_download_url":\s*"\K[^"]*linux[^"]*x64[^"]*\.AppImage' | head -1)"

if [[ -z "$APPIMAGE_URL" ]]; then
  # Fallback: try any AppImage URL
  APPIMAGE_URL="$(echo "$RELEASE_JSON" | grep -oP '"browser_download_url":\s*"\K[^"]*\.AppImage' | head -1)"
fi

if [[ -z "$APPIMAGE_URL" ]]; then
  err "Could not find Voquill AppImage download URL from GitHub releases."
  exit 1
fi

log "Downloading from: $APPIMAGE_URL"
mkdir -p "$(dirname "$INSTALL_PATH")"
curl -fL "$APPIMAGE_URL" -o "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

# Create .desktop file
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/voquill.desktop" <<DESKTOP
[Desktop Entry]
Name=Voquill
Comment=Voquill Writing App
Exec=$INSTALL_PATH --no-sandbox %F
Icon=voquill
Type=Application
Categories=Office;WordProcessor;
MimeType=text/plain;
StartupWMClass=Voquill
DESKTOP

log "Voquill installed to $INSTALL_PATH"
