#!/usr/bin/env bash
set -euo pipefail

VERSION=v22.15.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed node && [[ "$(node --version)" == "$VERSION" ]]; then
  log "Node.js $VERSION is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential python3 g++ make python3-pip

clone_or_pull https://github.com/nodejs/node.git node "$VERSION"

cd "$SRC_DIR/node"

log "Building Node.js $VERSION ..."
log "NOTE: Node.js builds from source can take a long time (30+ minutes). Please be patient."
./configure --prefix="$INSTALL_PREFIX"
make -j"$(nproc)"
sudo make install

log "Node.js $VERSION installed successfully."

cleanup_source node
