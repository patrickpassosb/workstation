#!/usr/bin/env bash
set -euo pipefail

VERSION=vercel@41.5.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/vercel/vercel.git vercel "$VERSION"

log "vercel-cli $VERSION cloned to $SRC_DIR/vercel"
log "To build manually (requires Node.js and npm):"
log "  cd $SRC_DIR/vercel"
log "  npm install"
log "  npx turbo run build --filter=vercel"
log "  cd packages/cli"
log "  sudo npm link"
