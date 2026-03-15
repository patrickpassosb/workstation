#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.22.1
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed starship; then
      log "starship is already installed: $(starship --version)"
    else
      log "Installing starship via official installer..."
      curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    ;;
  clone)
    clone_or_pull https://github.com/starship/starship.git starship "$VERSION"
    log "starship $VERSION cloned to $SRC_DIR/starship"
    log "To build manually (requires Rust/cargo):"
    log "  cd $SRC_DIR/starship"
    log "  cargo build --release"
    log "  sudo install -m 0755 target/release/starship $INSTALL_PREFIX/bin/starship"
    ;;
  build)
    clone_or_pull https://github.com/starship/starship.git starship "$VERSION"
    require_cmd cargo
    log "Building starship $VERSION..."
    cd "$SRC_DIR/starship"
    cargo build --release
    sudo install -m 0755 target/release/starship "$INSTALL_PREFIX/bin/starship"
    log "starship installed to $INSTALL_PREFIX/bin/starship"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
