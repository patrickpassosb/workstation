#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.0.55
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    ensure_node
    log "Installing opencode via npm..."
    npm install -g opencode-ai
    ;;
  clone)
    clone_or_pull https://github.com/opencode-ai/opencode.git opencode "$VERSION"
    log "opencode $VERSION cloned to $SRC_DIR/opencode"
    log "To build manually (requires Go):"
    log "  cd $SRC_DIR/opencode"
    log "  go build -o opencode ./cmd/opencode"
    log "  sudo install -m 0755 opencode $INSTALL_PREFIX/bin/opencode"
    ;;
  build)
    clone_or_pull https://github.com/opencode-ai/opencode.git opencode "$VERSION"
    require_cmd go
    log "Building opencode $VERSION..."
    cd "$SRC_DIR/opencode"
    go build -o opencode ./cmd/opencode
    sudo install -m 0755 opencode "$INSTALL_PREFIX/bin/opencode"
    log "opencode installed to $INSTALL_PREFIX/bin/opencode"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
