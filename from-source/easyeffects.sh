#!/usr/bin/env bash
set -euo pipefail

VERSION=v7.1.9

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed easyeffects && [[ "$(easyeffects --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "EasyEffects $VERSION is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential meson ninja-build git pkg-config libgtk-4-dev \
  libadwaita-1-dev libpipewire-0.3-dev liblilv-dev libsigc++-3.0-dev \
  libsamplerate0-dev libsndfile1-dev libbs2b-dev librubberband-dev libebur128-dev \
  liblsp-plug-in-dev libfftw3-dev libgsl-dev libspeexdsp-dev libnlopt-dev libfmt-dev

clone_or_pull https://github.com/wwmm/easyeffects.git easyeffects "$VERSION"

cd "$SRC_DIR/easyeffects"

log "Building EasyEffects $VERSION ..."
meson setup _build --prefix="$INSTALL_PREFIX"
ninja -C _build
sudo ninja -C _build install

log "EasyEffects $VERSION installed successfully."

cleanup_source easyeffects
