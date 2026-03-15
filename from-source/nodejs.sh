#!/usr/bin/env bash
set -euo pipefail

VERSION=v22.15.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/nodejs/node.git node "$VERSION"

log "Node.js $VERSION cloned to $SRC_DIR/node"
log "To build manually (WARNING: takes 30+ minutes, very CPU intensive):"
log "  sudo apt install build-essential python3 g++ make python3-pip"
log "  cd $SRC_DIR/node"
log "  ./configure --prefix=$INSTALL_PREFIX"
log "  make -j\$(nproc)"
log "  sudo make install"
