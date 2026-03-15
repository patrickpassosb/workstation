#!/usr/bin/env bash
set -euo pipefail

VERSION=v12.1.0
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    flatpak_install_if_missing org.flameshot.Flameshot
    ;;
  clone)
    clone_or_pull https://github.com/flameshot-org/flameshot.git flameshot "$VERSION"
    log "flameshot $VERSION cloned to $SRC_DIR/flameshot"
    log "To build manually:"
    log "  sudo apt install build-essential cmake qtbase5-dev qttools5-dev-tools qttools5-dev libqt5svg5-dev libqt5dbus5 pkg-config"
    log "  cd $SRC_DIR/flameshot"
    log "  mkdir -p build && cd build"
    log "  cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX .."
    log "  make -j\$(nproc)"
    log "  sudo make install"
    ;;
  build)
    clone_or_pull https://github.com/flameshot-org/flameshot.git flameshot "$VERSION"
    ensure_build_deps build-essential cmake qtbase5-dev qttools5-dev-tools qttools5-dev libqt5svg5-dev libqt5dbus5 pkg-config
    log "Building flameshot $VERSION..."
    cd "$SRC_DIR/flameshot"
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" ..
    make -j"$(nproc)"
    sudo make install
    log "flameshot installed"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
