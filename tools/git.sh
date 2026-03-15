#!/usr/bin/env bash
set -euo pipefail

VERSION=v2.48.1
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    apt_install_if_missing git
    ;;
  clone)
    clone_or_pull https://github.com/git/git.git git "$VERSION"
    log "git $VERSION cloned to $SRC_DIR/git"
    log "To build manually:"
    log "  sudo apt install build-essential libssl-dev libcurl4-openssl-dev libexpat1-dev gettext zlib1g-dev"
    log "  cd $SRC_DIR/git"
    log "  make prefix=$INSTALL_PREFIX -j\$(nproc) all"
    log "  sudo make prefix=$INSTALL_PREFIX install"
    ;;
  build)
    clone_or_pull https://github.com/git/git.git git "$VERSION"
    ensure_build_deps build-essential libssl-dev libcurl4-openssl-dev libexpat1-dev gettext zlib1g-dev
    log "Building git $VERSION..."
    cd "$SRC_DIR/git"
    make prefix="$INSTALL_PREFIX" -j"$(nproc)" all
    sudo make prefix="$INSTALL_PREFIX" install
    log "git installed to $INSTALL_PREFIX/bin/git"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
