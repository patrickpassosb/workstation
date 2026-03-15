#!/usr/bin/env bash
set -euo pipefail

VERSION=3.5a
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    apt_install_if_missing tmux
    ;;
  clone)
    clone_or_pull https://github.com/tmux/tmux.git tmux "$VERSION"
    log "tmux $VERSION cloned to $SRC_DIR/tmux"
    log "To build manually:"
    log "  sudo apt install build-essential autoconf automake libevent-dev libncurses-dev bison pkg-config"
    log "  cd $SRC_DIR/tmux"
    log "  sh autogen.sh"
    log "  ./configure --prefix=$INSTALL_PREFIX"
    log "  make -j\$(nproc)"
    log "  sudo make install"
    ;;
  build)
    clone_or_pull https://github.com/tmux/tmux.git tmux "$VERSION"
    ensure_build_deps build-essential autoconf automake libevent-dev libncurses-dev bison pkg-config
    log "Building tmux $VERSION..."
    cd "$SRC_DIR/tmux"
    sh autogen.sh
    ./configure --prefix="$INSTALL_PREFIX"
    make -j"$(nproc)"
    sudo make install
    log "tmux installed to $INSTALL_PREFIX/bin/tmux"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
