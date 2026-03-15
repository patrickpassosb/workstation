#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.61.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/junegunn/fzf.git fzf "$VERSION"

log "fzf $VERSION cloned to $SRC_DIR/fzf"
log "To build manually (requires Go):"
log "  cd $SRC_DIR/fzf"
log "  go build -o fzf ."
log "  sudo install -m 0755 fzf $INSTALL_PREFIX/bin/fzf"
