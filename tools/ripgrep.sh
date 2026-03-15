#!/usr/bin/env bash
set -euo pipefail

VERSION=14.1.1
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    apt_install_if_missing ripgrep
    ;;
  clone)
    clone_or_pull https://github.com/BurntSushi/ripgrep.git ripgrep "$VERSION"
    log "ripgrep $VERSION cloned to $SRC_DIR/ripgrep"
    log "To build manually (requires Rust/cargo):"
    log "  cd $SRC_DIR/ripgrep"
    log "  cargo build --release"
    log "  sudo install -m 0755 target/release/rg $INSTALL_PREFIX/bin/rg"
    ;;
  build)
    clone_or_pull https://github.com/BurntSushi/ripgrep.git ripgrep "$VERSION"
    require_cmd cargo
    log "Building ripgrep $VERSION..."
    cd "$SRC_DIR/ripgrep"
    cargo build --release
    sudo install -m 0755 target/release/rg "$INSTALL_PREFIX/bin/rg"
    log "ripgrep installed to $INSTALL_PREFIX/bin/rg"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
