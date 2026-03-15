#!/usr/bin/env bash
# Bitwarden Desktop is a TypeScript/Electron app.
set -euo pipefail

VERSION=desktop-v2025.1.3
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    flatpak_install_if_missing com.bitwarden.desktop
    ;;
  clone)
    clone_or_pull https://github.com/bitwarden/clients.git bitwarden "$VERSION"
    log "Bitwarden $VERSION cloned to $SRC_DIR/bitwarden"
    log "WARNING: Electron apps are complex to build from source and may fail."
    log "Consider installing via Flatpak instead: flatpak install flathub com.bitwarden.desktop"
    log "To build manually (requires Node.js and npm):"
    log "  cd $SRC_DIR/bitwarden/apps/desktop"
    log "  npm ci"
    log "  npm run build"
    log "  npm run dist:dir"
    ;;
  build)
    clone_or_pull https://github.com/bitwarden/clients.git bitwarden "$VERSION"
    ensure_node
    log "Building Bitwarden $VERSION..."
    cd "$SRC_DIR/bitwarden/apps/desktop"
    npm ci
    npm run build
    npm run dist:dir
    log "Bitwarden built to $SRC_DIR/bitwarden/apps/desktop/dist"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
