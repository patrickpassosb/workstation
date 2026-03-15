#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.3.4

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/google-gemini/gemini-cli.git gemini-cli "$VERSION"

log "gemini-cli $VERSION cloned to $SRC_DIR/gemini-cli"
log "To build manually (requires Node.js and npm):"
log "  cd $SRC_DIR/gemini-cli"
log "  npm install"
log "  npm run build"
log "  sudo npm link"
