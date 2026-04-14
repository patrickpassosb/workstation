#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.0.20
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    ensure_node
    log "Installing claude-code..."
    bun_or_npm_install_global @anthropic-ai/claude-code
    ;;
  clone)
    clone_or_pull https://github.com/anthropics/claude-code.git claude-code "$VERSION"
    log "claude-code $VERSION cloned to $SRC_DIR/claude-code"
    log "To build manually (requires Node.js; bun preferred, npm works):"
    log "  cd $SRC_DIR/claude-code"
    log "  bun install   # or: npm install"
    log "  npm run build"
    log "  sudo npm link"
    ;;
  build)
    clone_or_pull https://github.com/anthropics/claude-code.git claude-code "$VERSION"
    ensure_node
    log "Building claude-code $VERSION..."
    cd "$SRC_DIR/claude-code"
    bun_or_npm_install
    npm run build
    sudo npm link
    log "claude-code installed via npm link"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
