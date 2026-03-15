#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.1.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/andrewyng/context-hub.git context-hub "$VERSION"

log "context-hub $VERSION cloned to $SRC_DIR/context-hub"
log "To build manually (requires Node.js and npm):"
log "  cd $SRC_DIR/context-hub"
log "  npm install"
log "  npm run build"
log "  sudo npm link"
