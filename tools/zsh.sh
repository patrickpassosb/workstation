#!/usr/bin/env bash
set -euo pipefail

VERSION=zsh-5.9.1
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    apt_install_if_missing zsh
    ;;
  clone)
    clone_or_pull https://github.com/zsh-users/zsh.git zsh "$VERSION"
    log "zsh $VERSION cloned to $SRC_DIR/zsh"
    log "To build manually:"
    log "  sudo apt install build-essential autoconf libncurses-dev texinfo yodl"
    log "  cd $SRC_DIR/zsh"
    log "  ./Util/preconfig"
    log "  ./configure --prefix=$INSTALL_PREFIX"
    log "  make -j\$(nproc)"
    log "  sudo make install"
    ;;
  build)
    clone_or_pull https://github.com/zsh-users/zsh.git zsh "$VERSION"
    ensure_build_deps build-essential autoconf libncurses-dev texinfo yodl
    log "Building zsh $VERSION..."
    cd "$SRC_DIR/zsh"
    ./Util/preconfig
    ./configure --prefix="$INSTALL_PREFIX"
    make -j"$(nproc)"
    sudo make install
    log "zsh installed to $INSTALL_PREFIX/bin/zsh"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
