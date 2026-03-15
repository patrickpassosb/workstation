#!/usr/bin/env bash
set -euo pipefail

VERSION=v2.48.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/git/git.git git "$VERSION"

log "git $VERSION cloned to $SRC_DIR/git"
log "To build manually:"
log "  sudo apt install build-essential libssl-dev libcurl4-openssl-dev libexpat1-dev gettext zlib1g-dev"
log "  cd $SRC_DIR/git"
log "  make prefix=$INSTALL_PREFIX -j\$(nproc) all"
log "  sudo make prefix=$INSTALL_PREFIX install"
