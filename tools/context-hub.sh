#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.1.0
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    ensure_node
    log "Installing context-hub via npm..."
    npm install -g context-hub
    ;;
  clone)
    clone_or_pull https://github.com/andrewyng/context-hub.git context-hub "$VERSION"
    log "context-hub $VERSION cloned to $SRC_DIR/context-hub"
    log "To build manually (requires Node.js and npm):"
    log "  cd $SRC_DIR/context-hub"
    log "  npm install"
    log "  npm run build"
    log "  sudo npm link"
    ;;
  build)
    clone_or_pull https://github.com/andrewyng/context-hub.git context-hub "$VERSION"
    ensure_node
    log "Building context-hub $VERSION..."
    cd "$SRC_DIR/context-hub"
    npm install
    npm run build
    sudo npm link
    log "context-hub installed via npm link"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
