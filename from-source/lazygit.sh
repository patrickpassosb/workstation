#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.50.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/jesseduffield/lazygit.git lazygit "$VERSION"

log "lazygit $VERSION cloned to $SRC_DIR/lazygit"
log "To build manually (requires Go):"
log "  cd $SRC_DIR/lazygit"
log "  go build -o lazygit ."
log "  sudo install -m 0755 lazygit $INSTALL_PREFIX/bin/lazygit"
