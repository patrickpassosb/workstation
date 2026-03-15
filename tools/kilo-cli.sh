#!/usr/bin/env bash
set -euo pipefail

VERSION=v3.16.5
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    ensure_node
    log "Installing kilo-cli via npm..."
    npm install -g kilocode
    ;;
  clone)
    clone_or_pull https://github.com/Kilo-Org/kilocode.git kilocode "$VERSION"
    log "kilo-cli $VERSION cloned to $SRC_DIR/kilocode"
    log "To build manually (requires Node.js and npm):"
    log "  cd $SRC_DIR/kilocode"
    log "  npm install"
    log "  npm run build"
    log "  sudo npm link"
    ;;
  build)
    clone_or_pull https://github.com/Kilo-Org/kilocode.git kilocode "$VERSION"
    ensure_node
    log "Building kilo-cli $VERSION..."
    cd "$SRC_DIR/kilocode"
    npm install
    npm run build
    sudo npm link
    log "kilo-cli installed via npm link"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
