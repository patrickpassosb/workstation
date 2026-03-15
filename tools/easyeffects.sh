#!/usr/bin/env bash
set -euo pipefail

VERSION=v7.1.9
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    flatpak_install_if_missing com.github.wwmm.easyeffects
    ;;
  clone)
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
    ;;
  build)
    clone_or_pull https://github.com/wwmm/easyeffects.git easyeffects "$VERSION"
    ensure_build_deps build-essential meson ninja-build pkg-config libgtk-4-dev \
      libadwaita-1-dev libpipewire-0.3-dev liblilv-dev libsigc++-3.0-dev \
      libsamplerate0-dev libsndfile1-dev libbs2b-dev librubberband-dev libebur128-dev \
      liblsp-plug-in-dev libfftw3-dev libgsl-dev libspeexdsp-dev libnlopt-dev libfmt-dev
    log "Building EasyEffects $VERSION..."
    cd "$SRC_DIR/easyeffects"
    meson setup _build --prefix="$INSTALL_PREFIX"
    ninja -C _build
    sudo ninja -C _build install
    log "EasyEffects installed"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
