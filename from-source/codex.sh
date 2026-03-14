#!/usr/bin/env bash
# Build OpenAI Codex CLI from source
# Requires: node, npm
set -euo pipefail

VERSION=v0.1.2505302101

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed codex && [[ "$(codex --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "codex $VERSION is already installed, skipping."
  exit 0
fi

require_cmd node
require_cmd npm

clone_or_pull https://github.com/openai/codex.git codex "$VERSION"

cd "$SRC_DIR/codex/codex-cli"

log "Building codex $VERSION ..."
npm install
npm run build

log "Linking codex globally ..."
sudo npm link

log "codex $VERSION installed successfully."

cleanup_source codex
