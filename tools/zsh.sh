#!/usr/bin/env bash
set -euo pipefail

VERSION=zsh-5.9.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/zsh-users/zsh.git zsh "$VERSION"

log "zsh $VERSION cloned to $SRC_DIR/zsh"
log "To build manually:"
log "  sudo apt install build-essential autoconf libncurses-dev texinfo yodl"
log "  cd $SRC_DIR/zsh"
log "  ./Util/preconfig"
log "  ./configure --prefix=$INSTALL_PREFIX"
log "  make -j\$(nproc)"
log "  sudo make install"
