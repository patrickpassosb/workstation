#!/usr/bin/env bash
set -euo pipefail

VERSION=3.4.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/htop-dev/htop.git htop "$VERSION"

log "htop $VERSION cloned to $SRC_DIR/htop"
log "To build manually:"
log "  sudo apt install build-essential autoconf automake libncursesw5-dev"
log "  cd $SRC_DIR/htop"
log "  ./autogen.sh"
log "  ./configure --prefix=$INSTALL_PREFIX"
log "  make -j\$(nproc)"
log "  sudo make install"
