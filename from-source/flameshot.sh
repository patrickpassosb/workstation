#!/usr/bin/env bash
set -euo pipefail

VERSION=v12.1.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed flameshot && [[ "$(flameshot --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "flameshot $VERSION is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential cmake qtbase5-dev qttools5-dev-tools qttools5-dev \
  libqt5svg5-dev libqt5dbus5 pkg-config

clone_or_pull https://github.com/flameshot-org/flameshot.git flameshot "$VERSION"

cd "$SRC_DIR/flameshot"

log "Building flameshot $VERSION ..."
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" ..
make -j"$(nproc)"
sudo make install

log "flameshot $VERSION installed successfully."

cleanup_source flameshot
