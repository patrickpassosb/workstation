#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed cursor; then
  log "Cursor is already installed."
  exit 0
fi

APPIMAGE_DIR="$HOME/AppImage"
APPIMAGE_PATH="$APPIMAGE_DIR/cursor.AppImage"

if [[ -f "$APPIMAGE_PATH" ]]; then
  log "Cursor AppImage already exists at $APPIMAGE_PATH"
  exit 0
fi

log "Installing Cursor editor..."

mkdir -p "$APPIMAGE_DIR"
curl -fL "https://download.cursor.com/linux/appImage/x64" -o "$APPIMAGE_PATH"
chmod +x "$APPIMAGE_PATH"

# Create .desktop file for application menu integration
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/cursor.desktop" <<DESKTOP
[Desktop Entry]
Name=Cursor
Comment=Cursor AI Code Editor
Exec=$APPIMAGE_PATH --no-sandbox %F
Icon=cursor
Type=Application
Categories=Development;IDE;TextEditor;
MimeType=text/plain;
StartupWMClass=Cursor
DESKTOP

log "Cursor installed to $APPIMAGE_PATH"
