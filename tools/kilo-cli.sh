#!/usr/bin/env bash
set -euo pipefail

VERSION=v3.16.5
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    ensure_node
    log "Installing kilo-cli..."
    bun_or_npm_install_global kilocode
    ;;
  clone)
    clone_or_pull https://github.com/Kilo-Org/kilocode.git kilocode "$VERSION"
    log "kilo-cli $VERSION cloned to $SRC_DIR/kilocode"
    log "To build manually (requires Node.js; bun preferred, npm works):"
    log "  cd $SRC_DIR/kilocode"
    log "  bun install   # or: npm install"
    log "  npm run build"
    log "  sudo npm link"
    ;;
  build)
    clone_or_pull https://github.com/Kilo-Org/kilocode.git kilocode "$VERSION"
    ensure_node
    log "Building kilo-cli $VERSION..."
    cd "$SRC_DIR/kilocode"
    bun_or_npm_install
    npm run build
    sudo npm link
    log "kilo-cli installed via npm link"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
