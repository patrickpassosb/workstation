#!/usr/bin/env bash
set -euo pipefail

VERSION=v22.15.0
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed node; then
      log "Node.js is already installed: $(node --version)"
    else
      ensure_nvm
      log "Installing Node.js LTS via nvm..."
      nvm install --lts
      log "Node.js installed: $(node --version)"
    fi
    ;;
  clone)
    clone_or_pull https://github.com/nodejs/node.git node "$VERSION"
    log "Node.js $VERSION cloned to $SRC_DIR/node"
    log "To build manually (WARNING: takes 30+ minutes, very CPU intensive):"
    log "  sudo apt install build-essential python3 g++ make python3-pip"
    log "  cd $SRC_DIR/node"
    log "  ./configure --prefix=$INSTALL_PREFIX"
    log "  make -j\$(nproc)"
    log "  sudo make install"
    ;;
  build)
    clone_or_pull https://github.com/nodejs/node.git node "$VERSION"
    ensure_build_deps build-essential python3 g++ make
    log "Building Node.js $VERSION (this will take a long time)..."
    cd "$SRC_DIR/node"
    ./configure --prefix="$INSTALL_PREFIX"
    make -j"$(nproc)"
    sudo make install
    log "Node.js installed to $INSTALL_PREFIX/bin/node"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
