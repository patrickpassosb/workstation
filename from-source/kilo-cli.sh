#!/usr/bin/env bash
set -euo pipefail

VERSION=v3.16.5

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/Kilo-Org/kilocode.git kilocode "$VERSION"

log "kilo-cli $VERSION cloned to $SRC_DIR/kilocode"
log "To build manually (requires Node.js and npm):"
log "  cd $SRC_DIR/kilocode"
log "  npm install"
log "  npm run build"
log "  sudo npm link"
