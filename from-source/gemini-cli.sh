#!/usr/bin/env bash
# Build Gemini CLI from source
# Requires: node, npm
set -euo pipefail

VERSION=v0.3.4

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed gemini && [[ "$(gemini --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "gemini-cli $VERSION is already installed, skipping."
  exit 0
fi

require_cmd node
require_cmd npm

clone_or_pull https://github.com/google-gemini/gemini-cli.git gemini-cli "$VERSION"

cd "$SRC_DIR/gemini-cli"

log "Building gemini-cli $VERSION ..."
npm install
npm run build

log "Linking gemini globally ..."
sudo npm link

log "gemini-cli $VERSION installed successfully."

cleanup_source gemini-cli
