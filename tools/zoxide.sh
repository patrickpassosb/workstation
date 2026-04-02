#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.9.6
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed zoxide; then
      log "zoxide is already installed: $(zoxide --version)"
    else
      # Try apt first (available on Ubuntu 22.04+)
      if apt-cache show zoxide > /dev/null 2>&1; then
        apt_install_if_missing zoxide
      else
        log "Installing zoxide via official installer..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
      fi
    fi
    ;;
  clone)
    clone_or_pull https://github.com/ajeetdsouza/zoxide.git zoxide "$VERSION"
    log "zoxide $VERSION cloned to $SRC_DIR/zoxide"
    log "To build manually (requires Rust/cargo):"
    log "  cd $SRC_DIR/zoxide"
    log "  cargo build --release"
    log "  sudo install -m 0755 target/release/zoxide $INSTALL_PREFIX/bin/zoxide"
    ;;
  build)
    clone_or_pull https://github.com/ajeetdsouza/zoxide.git zoxide "$VERSION"
    require_cmd cargo
    log "Building zoxide $VERSION..."
    cd "$SRC_DIR/zoxide"
    cargo build --release
    sudo install -m 0755 target/release/zoxide "$INSTALL_PREFIX/bin/zoxide"
    log "zoxide installed to $INSTALL_PREFIX/bin/zoxide"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
