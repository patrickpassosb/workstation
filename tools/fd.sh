#!/usr/bin/env bash
set -euo pipefail

VERSION=v10.2.0
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    apt_install_if_missing fd-find
    ;;
  clone)
    clone_or_pull https://github.com/sharkdp/fd.git fd "$VERSION"
    log "fd $VERSION cloned to $SRC_DIR/fd"
    log "To build manually (requires Rust/cargo):"
    log "  cd $SRC_DIR/fd"
    log "  cargo build --release"
    log "  sudo install -m 0755 target/release/fd $INSTALL_PREFIX/bin/fd"
    ;;
  build)
    clone_or_pull https://github.com/sharkdp/fd.git fd "$VERSION"
    require_cmd cargo
    log "Building fd $VERSION..."
    cd "$SRC_DIR/fd"
    cargo build --release
    sudo install -m 0755 target/release/fd "$INSTALL_PREFIX/bin/fd"
    log "fd installed to $INSTALL_PREFIX/bin/fd"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
