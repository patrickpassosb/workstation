#!/usr/bin/env bash
set -euo pipefail

VERSION=0.7.2
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed uv; then
      log "uv is already installed: $(uv --version)"
    else
      log "Installing uv via official installer..."
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    ;;
  clone)
    clone_or_pull https://github.com/astral-sh/uv.git uv "$VERSION"
    log "uv $VERSION cloned to $SRC_DIR/uv"
    log "To build manually (requires Rust/cargo):"
    log "  cd $SRC_DIR/uv"
    log "  cargo build --release"
    log "  sudo install -m 0755 target/release/uv $INSTALL_PREFIX/bin/uv"
    log "  sudo install -m 0755 target/release/uvx $INSTALL_PREFIX/bin/uvx  # if uvx exists"
    ;;
  build)
    clone_or_pull https://github.com/astral-sh/uv.git uv "$VERSION"
    require_cmd cargo
    log "Building uv $VERSION..."
    cd "$SRC_DIR/uv"
    cargo build --release
    sudo install -m 0755 target/release/uv "$INSTALL_PREFIX/bin/uv"
    [[ -f target/release/uvx ]] && sudo install -m 0755 target/release/uvx "$INSTALL_PREFIX/bin/uvx"
    log "uv installed to $INSTALL_PREFIX/bin/uv"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
