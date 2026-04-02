#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.3.4
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    ensure_node
    log "Installing gemini-cli via npm..."
    npm install -g @google/gemini-cli
    ;;
  clone)
    clone_or_pull https://github.com/google-gemini/gemini-cli.git gemini-cli "$VERSION"
    log "gemini-cli $VERSION cloned to $SRC_DIR/gemini-cli"
    log "To build manually (requires Node.js and npm):"
    log "  cd $SRC_DIR/gemini-cli"
    log "  npm install"
    log "  npm run build"
    log "  sudo npm link"
    ;;
  build)
    clone_or_pull https://github.com/google-gemini/gemini-cli.git gemini-cli "$VERSION"
    ensure_node
    log "Building gemini-cli $VERSION..."
    cd "$SRC_DIR/gemini-cli"
    npm install
    npm run build
    sudo npm link
    log "gemini-cli installed via npm link"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
