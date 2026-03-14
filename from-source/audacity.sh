#!/usr/bin/env bash
set -euo pipefail

VERSION=Audacity-3.7.3

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed audacity && [[ "$(audacity --version 2>&1)" == *"${VERSION#Audacity-}"* ]]; then
  log "Audacity $VERSION is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential cmake git python3 pkg-config libgtk-3-dev \
  libwxgtk3.2-dev libexpat1-dev libmp3lame-dev libsndfile1-dev libsoxr-dev \
  portaudio19-dev libsqlite3-dev libasound2-dev libflac-dev libid3tag0-dev \
  libmad0-dev libogg-dev libopus-dev libvorbis-dev libmpg123-dev

clone_or_pull https://github.com/audacity/audacity.git audacity "$VERSION"

cd "$SRC_DIR/audacity"

log "Building Audacity $VERSION ..."
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" ..
make -j"$(nproc)"
sudo make install

log "Audacity $VERSION installed successfully."

cleanup_source audacity
