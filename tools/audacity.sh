#!/usr/bin/env bash
set -euo pipefail

VERSION=Audacity-3.7.3
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    flatpak_install_if_missing org.audacityteam.Audacity
    ;;
  clone)
    clone_or_pull https://github.com/audacity/audacity.git audacity "$VERSION"
    log "Audacity $VERSION cloned to $SRC_DIR/audacity"
    log "To build manually:"
    log "  sudo apt install build-essential cmake git python3 pkg-config libgtk-3-dev \\"
    log "    libwxgtk3.2-dev libexpat1-dev libmp3lame-dev libsndfile1-dev libsoxr-dev \\"
    log "    portaudio19-dev libsqlite3-dev libasound2-dev libflac-dev libid3tag0-dev \\"
    log "    libmad0-dev libogg-dev libopus-dev libvorbis-dev libmpg123-dev"
    log "  cd $SRC_DIR/audacity"
    log "  mkdir -p build && cd build"
    log "  cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX .."
    log "  make -j\$(nproc)"
    log "  sudo make install"
    ;;
  build)
    clone_or_pull https://github.com/audacity/audacity.git audacity "$VERSION"
    ensure_build_deps build-essential cmake python3 pkg-config libgtk-3-dev \
      libwxgtk3.2-dev libexpat1-dev libmp3lame-dev libsndfile1-dev libsoxr-dev \
      portaudio19-dev libsqlite3-dev libasound2-dev libflac-dev libid3tag0-dev \
      libmad0-dev libogg-dev libopus-dev libvorbis-dev libmpg123-dev
    log "Building Audacity $VERSION..."
    cd "$SRC_DIR/audacity"
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" ..
    make -j"$(nproc)"
    sudo make install
    log "Audacity installed"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
