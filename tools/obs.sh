#!/usr/bin/env bash
set -euo pipefail

VERSION=31.0.2

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/obsproject/obs-studio.git obs-studio "$VERSION"

log "OBS Studio $VERSION cloned to $SRC_DIR/obs-studio"
log "To build manually (many dependencies required):"
log "  sudo apt install build-essential cmake git pkg-config libx11-dev libxcb-randr0-dev \\"
log "    libxcb-shm0-dev libxcb-xinerama0-dev libxcb-composite0-dev libxcomposite-dev \\"
log "    libxinerama-dev libxcb-xfixes0-dev libxcb1-dev libx11-xcb-dev libgles2-mesa-dev \\"
log "    libwayland-dev libpulse-dev libv4l-dev libgl1-mesa-dev libjansson-dev \\"
log "    libluajit-5.1-dev python3-dev libcurl4-openssl-dev libmbedtls-dev libfdk-aac-dev \\"
log "    libpipewire-0.3-dev qtbase6-dev qt6-base-dev libqt6svg6-dev qt6-wayland-dev \\"
log "    libsrt-openssl-dev librist-dev"
log "  cd $SRC_DIR/obs-studio"
log "  git submodule update --init --recursive"
log "  mkdir -p build && cd build"
log "  cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DENABLE_BROWSER=OFF .."
log "  make -j\$(nproc)"
log "  sudo make install"
