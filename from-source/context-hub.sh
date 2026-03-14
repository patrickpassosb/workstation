#!/usr/bin/env bash
# Build ContextHub from source
# Requires: node, npm
set -euo pipefail

VERSION=v0.1.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed contexthub && [[ "$(contexthub --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "context-hub $VERSION is already installed, skipping."
  exit 0
fi

require_cmd node
require_cmd npm

clone_or_pull https://github.com/andrewyng/context-hub.git context-hub "$VERSION"

cd "$SRC_DIR/context-hub"

log "Building context-hub $VERSION ..."
npm install
npm run build

log "Linking contexthub globally ..."
sudo npm link

log "context-hub $VERSION installed successfully."

cleanup_source context-hub
