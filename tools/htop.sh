#!/usr/bin/env bash
set -euo pipefail

VERSION=3.4.1
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    apt_install_if_missing htop
    ;;
  clone)
    clone_or_pull https://github.com/htop-dev/htop.git htop "$VERSION"
    log "htop $VERSION cloned to $SRC_DIR/htop"
    log "To build manually:"
    log "  sudo apt install build-essential autoconf automake libncursesw5-dev"
    log "  cd $SRC_DIR/htop"
    log "  ./autogen.sh"
    log "  ./configure --prefix=$INSTALL_PREFIX"
    log "  make -j\$(nproc)"
    log "  sudo make install"
    ;;
  build)
    clone_or_pull https://github.com/htop-dev/htop.git htop "$VERSION"
    ensure_build_deps build-essential autoconf automake libncursesw5-dev
    log "Building htop $VERSION..."
    cd "$SRC_DIR/htop"
    ./autogen.sh
    ./configure --prefix="$INSTALL_PREFIX"
    make -j"$(nproc)"
    sudo make install
    log "htop installed to $INSTALL_PREFIX/bin/htop"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
