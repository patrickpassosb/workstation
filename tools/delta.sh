#!/usr/bin/env bash
set -euo pipefail

VERSION=0.18.2
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed delta; then
      log "delta is already installed: $(delta --version)"
    else
      # Install from GitHub release (not in standard Ubuntu repos)
      log "Installing delta from GitHub release..."
      local tag="$VERSION"
      local asset="git-delta_${VERSION}_amd64.deb"
      local url="https://github.com/dandavison/delta/releases/download/${tag}/${asset}"
      local tmp_deb
      tmp_deb="$(mktemp --suffix=.deb)"
      curl -fSL "$url" -o "$tmp_deb"
      sudo dpkg -i "$tmp_deb"
      rm -f "$tmp_deb"
      log "delta installed: $(delta --version)"
    fi
    ;;
  clone)
    clone_or_pull https://github.com/dandavison/delta.git delta "$VERSION"
    log "delta $VERSION cloned to $SRC_DIR/delta"
    log "To build manually (requires Rust/cargo):"
    log "  cd $SRC_DIR/delta"
    log "  cargo build --release"
    log "  sudo install -m 0755 target/release/delta $INSTALL_PREFIX/bin/delta"
    ;;
  build)
    clone_or_pull https://github.com/dandavison/delta.git delta "$VERSION"
    require_cmd cargo
    log "Building delta $VERSION..."
    cd "$SRC_DIR/delta"
    cargo build --release
    sudo install -m 0755 target/release/delta "$INSTALL_PREFIX/bin/delta"
    log "delta installed to $INSTALL_PREFIX/bin/delta"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
