#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.25.0
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed bat || is_installed batcat; then
      log "bat is already installed"
    else
      apt_install_if_missing bat
      # On Debian/Ubuntu the binary is named 'batcat' due to name conflict.
      # Create a symlink so 'bat' works everywhere.
      if is_installed batcat && ! is_installed bat; then
        sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
        log "Created symlink: bat → batcat"
      fi
    fi
    ;;
  clone)
    clone_or_pull https://github.com/sharkdp/bat.git bat "$VERSION"
    log "bat $VERSION cloned to $SRC_DIR/bat"
    log "To build manually (requires Rust/cargo):"
    log "  cd $SRC_DIR/bat"
    log "  cargo build --release"
    log "  sudo install -m 0755 target/release/bat $INSTALL_PREFIX/bin/bat"
    ;;
  build)
    clone_or_pull https://github.com/sharkdp/bat.git bat "$VERSION"
    require_cmd cargo
    log "Building bat $VERSION..."
    cd "$SRC_DIR/bat"
    cargo build --release
    sudo install -m 0755 target/release/bat "$INSTALL_PREFIX/bin/bat"
    log "bat installed to $INSTALL_PREFIX/bin/bat"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
