#!/usr/bin/env bash
set -euo pipefail

VERSION=jq-1.7.1
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    apt_install_if_missing jq
    ;;
  clone)
    clone_or_pull https://github.com/jqlang/jq.git jq "$VERSION"
    log "jq $VERSION cloned to $SRC_DIR/jq"
    log "To build manually:"
    log "  sudo apt install build-essential autoconf automake libtool"
    log "  cd $SRC_DIR/jq"
    log "  git submodule update --init"
    log "  autoreconf -i"
    log "  ./configure --prefix=$INSTALL_PREFIX --with-oniguruma=builtin"
    log "  make -j\$(nproc)"
    log "  sudo make install"
    ;;
  build)
    clone_or_pull https://github.com/jqlang/jq.git jq "$VERSION"
    ensure_build_deps build-essential autoconf automake libtool
    log "Building jq $VERSION..."
    cd "$SRC_DIR/jq"
    git submodule update --init
    autoreconf -i
    ./configure --prefix="$INSTALL_PREFIX" --with-oniguruma=builtin
    make -j"$(nproc)"
    sudo make install
    log "jq installed to $INSTALL_PREFIX/bin/jq"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
