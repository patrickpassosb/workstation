#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.0.20

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/anthropics/claude-code.git claude-code "$VERSION"

log "claude-code $VERSION cloned to $SRC_DIR/claude-code"
log "To build manually (requires Node.js and npm):"
log "  cd $SRC_DIR/claude-code"
log "  npm install"
log "  npm run build"
log "  sudo npm link"
