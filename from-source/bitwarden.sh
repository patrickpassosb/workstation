#!/usr/bin/env bash
# Bitwarden Desktop is a TypeScript/Electron app.
# Consider installing via Flatpak instead: flatpak install flathub com.bitwarden.desktop
set -euo pipefail

VERSION=desktop-v2025.1.3

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/bitwarden/clients.git bitwarden "$VERSION"

log "Bitwarden $VERSION cloned to $SRC_DIR/bitwarden"
log "WARNING: Electron apps are complex to build from source and may fail."
log "Consider installing via Flatpak instead: flatpak install flathub com.bitwarden.desktop"
log "To build manually (requires Node.js and npm):"
log "  cd $SRC_DIR/bitwarden/apps/desktop"
log "  npm ci"
log "  npm run build"
log "  npm run dist:dir"
