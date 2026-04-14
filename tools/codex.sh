#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.1.2505302101
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    ensure_node
    log "Installing codex..."
    bun_or_npm_install_global @openai/codex
    ;;
  clone)
    clone_or_pull https://github.com/openai/codex.git codex "$VERSION"
    log "codex $VERSION cloned to $SRC_DIR/codex"
    log "To build manually (requires Node.js; bun preferred, npm works):"
    log "  cd $SRC_DIR/codex/codex-cli"
    log "  bun install   # or: npm install"
    log "  npm run build"
    log "  sudo npm link"
    ;;
  build)
    clone_or_pull https://github.com/openai/codex.git codex "$VERSION"
    ensure_node
    log "Building codex $VERSION..."
    cd "$SRC_DIR/codex/codex-cli"
    bun_or_npm_install
    npm run build
    sudo npm link
    log "codex installed via npm link"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
