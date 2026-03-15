#!/usr/bin/env bash
set -euo pipefail

VERSION=3.5a

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/tmux/tmux.git tmux "$VERSION"

log "tmux $VERSION cloned to $SRC_DIR/tmux"
log "To build manually:"
log "  sudo apt install build-essential autoconf automake libevent-dev libncurses-dev bison pkg-config"
log "  cd $SRC_DIR/tmux"
log "  sh autogen.sh"
log "  ./configure --prefix=$INSTALL_PREFIX"
log "  make -j\$(nproc)"
log "  sudo make install"
