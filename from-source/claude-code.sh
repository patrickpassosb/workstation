#!/usr/bin/env bash
# Build Claude Code CLI from source
# Requires: node, npm
set -euo pipefail

VERSION=v1.0.20

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed claude && [[ "$(claude --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "claude-code $VERSION is already installed, skipping."
  exit 0
fi

require_cmd node
require_cmd npm

clone_or_pull https://github.com/anthropics/claude-code.git claude-code "$VERSION"

cd "$SRC_DIR/claude-code"

log "Building claude-code $VERSION ..."
npm install
npm run build

log "Linking claude globally ..."
sudo npm link

log "claude-code $VERSION installed successfully."

cleanup_source claude-code
