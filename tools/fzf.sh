#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.61.1
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    apt_install_if_missing fzf
    ;;
  clone)
    clone_or_pull https://github.com/junegunn/fzf.git fzf "$VERSION"
    log "fzf $VERSION cloned to $SRC_DIR/fzf"
    log "To build manually (requires Go):"
    log "  cd $SRC_DIR/fzf"
    log "  go build -o fzf ."
    log "  sudo install -m 0755 fzf $INSTALL_PREFIX/bin/fzf"
    ;;
  build)
    clone_or_pull https://github.com/junegunn/fzf.git fzf "$VERSION"
    require_cmd go
    log "Building fzf $VERSION..."
    cd "$SRC_DIR/fzf"
    go build -o fzf .
    sudo install -m 0755 fzf "$INSTALL_PREFIX/bin/fzf"
    log "fzf installed to $INSTALL_PREFIX/bin/fzf"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
