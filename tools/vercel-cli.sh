#!/usr/bin/env bash
set -euo pipefail

VERSION=vercel@41.5.0
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    ensure_node
    log "Installing vercel-cli via npm..."
    npm install -g vercel
    ;;
  clone)
    clone_or_pull https://github.com/vercel/vercel.git vercel "$VERSION"
    log "vercel-cli $VERSION cloned to $SRC_DIR/vercel"
    log "To build manually (requires Node.js and npm):"
    log "  cd $SRC_DIR/vercel"
    log "  npm install"
    log "  npx turbo run build --filter=vercel"
    log "  cd packages/cli"
    log "  sudo npm link"
    ;;
  build)
    clone_or_pull https://github.com/vercel/vercel.git vercel "$VERSION"
    ensure_node
    log "Building vercel-cli $VERSION..."
    cd "$SRC_DIR/vercel"
    npm install
    npx turbo run build --filter=vercel
    cd packages/cli
    sudo npm link
    log "vercel-cli installed via npm link"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
