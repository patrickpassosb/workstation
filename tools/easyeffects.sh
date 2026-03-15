#!/usr/bin/env bash
set -euo pipefail

VERSION=v7.1.9

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/wwmm/easyeffects.git easyeffects "$VERSION"

log "EasyEffects $VERSION cloned to $SRC_DIR/easyeffects"
log "To build manually:"
log "  sudo apt install build-essential meson ninja-build git pkg-config libgtk-4-dev \\"
log "    libadwaita-1-dev libpipewire-0.3-dev liblilv-dev libsigc++-3.0-dev \\"
log "    libsamplerate0-dev libsndfile1-dev libbs2b-dev librubberband-dev libebur128-dev \\"
log "    liblsp-plug-in-dev libfftw3-dev libgsl-dev libspeexdsp-dev libnlopt-dev libfmt-dev"
log "  cd $SRC_DIR/easyeffects"
log "  meson setup _build --prefix=$INSTALL_PREFIX"
log "  ninja -C _build"
log "  sudo ninja -C _build install"
