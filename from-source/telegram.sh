#!/usr/bin/env bash
# Telegram Desktop (Nicegram) - extremely complex build.
# This script clones the source only. If you prefer an easy install, use Flatpak:
#   flatpak install flathub org.nicegram.nicegram
set -euo pipefail

VERSION=v5.12.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/nicegram/nicegram-desktop.git nicegram-desktop "$VERSION"

log "Telegram Desktop (Nicegram) $VERSION cloned to $SRC_DIR/nicegram-desktop"
log "WARNING: This is an extremely complex build and may fail."
log "Consider installing via Flatpak instead: flatpak install flathub org.nicegram.nicegram"
log "To build manually:"
log "  sudo apt install build-essential cmake ninja-build git python3 pkg-config \\"
log "    qtbase6-dev qt6-base-dev libqt6svg6-dev qt6-wayland-dev libfmt-dev liblz4-dev \\"
log "    libxxhash-dev libglibmm-2.68-dev libsigc++-3.0-dev"
log "  cd $SRC_DIR/nicegram-desktop"
log "  git submodule update --init --recursive"
log "  mkdir -p build && cd build"
log "  cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -GNinja .."
log "  ninja -j\$(nproc)"
log "  sudo ninja install"
