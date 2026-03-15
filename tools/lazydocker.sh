#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.24.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/jesseduffield/lazydocker.git lazydocker "$VERSION"

log "lazydocker $VERSION cloned to $SRC_DIR/lazydocker"
log "To build manually (requires Go):"
log "  cd $SRC_DIR/lazydocker"
log "  go build -o lazydocker ."
log "  sudo install -m 0755 lazydocker $INSTALL_PREFIX/bin/lazydocker"
