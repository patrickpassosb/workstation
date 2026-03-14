#!/usr/bin/env bash
set -euo pipefail

VERSION=31.0.2

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed obs && [[ "$(obs --version 2>&1)" == *"$VERSION"* ]]; then
  log "OBS Studio $VERSION is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential cmake git pkg-config libx11-dev libxcb-randr0-dev \
  libxcb-shm0-dev libxcb-xinerama0-dev libxcb-composite0-dev libxcomposite-dev \
  libxinerama-dev libxcb-xfixes0-dev libxcb1-dev libx11-xcb-dev libgles2-mesa-dev \
  libwayland-dev libpulse-dev libv4l-dev libgl1-mesa-dev libjansson-dev \
  libluajit-5.1-dev python3-dev libcurl4-openssl-dev libmbedtls-dev libfdk-aac-dev \
  libpipewire-0.3-dev qtbase6-dev qt6-base-dev libqt6svg6-dev qt6-wayland-dev \
  libsrt-openssl-dev librist-dev

clone_or_pull https://github.com/obsproject/obs-studio.git obs-studio "$VERSION"

cd "$SRC_DIR/obs-studio"

log "Building OBS Studio $VERSION ..."
git submodule update --init --recursive
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" -DENABLE_BROWSER=OFF ..
make -j"$(nproc)"
sudo make install

log "OBS Studio $VERSION installed successfully."

cleanup_source obs-studio
