#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.1.2505302101

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/openai/codex.git codex "$VERSION"

log "codex $VERSION cloned to $SRC_DIR/codex"
log "To build manually (requires Node.js and npm):"
log "  cd $SRC_DIR/codex/codex-cli"
log "  npm install"
log "  npm run build"
log "  sudo npm link"
