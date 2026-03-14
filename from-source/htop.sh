#!/usr/bin/env bash
set -euo pipefail

VERSION=3.4.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed htop && [[ "$(htop --version)" == *"$VERSION"* ]]; then
  log "htop $VERSION is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential autoconf automake libncursesw5-dev

clone_or_pull https://github.com/htop-dev/htop.git htop "$VERSION"

cd "$SRC_DIR/htop"

log "Building htop $VERSION ..."
./autogen.sh
./configure --prefix="$INSTALL_PREFIX"
make -j"$(nproc)"
sudo make install

log "htop $VERSION installed successfully."

cleanup_source htop
