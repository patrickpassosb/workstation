#!/usr/bin/env bash
set -euo pipefail

VERSION=jq-1.7.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/jqlang/jq.git jq "$VERSION"

log "jq $VERSION cloned to $SRC_DIR/jq"
log "To build manually:"
log "  sudo apt install build-essential autoconf automake libtool"
log "  cd $SRC_DIR/jq"
log "  git submodule update --init"
log "  autoreconf -i"
log "  ./configure --prefix=$INSTALL_PREFIX --with-oniguruma=builtin"
log "  make -j\$(nproc)"
log "  sudo make install"
