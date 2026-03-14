#!/usr/bin/env bash
# Build Kilo Code CLI from source
# Requires: node, npm
# Note: This builds the CLI component. The VS Code/Cursor extension is
#       installed separately within the editor.
set -euo pipefail

VERSION=v3.16.5

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed kilo && [[ "$(kilo --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "kilo-cli $VERSION is already installed, skipping."
  exit 0
fi

require_cmd node
require_cmd npm

clone_or_pull https://github.com/Kilo-Org/kilocode.git kilocode "$VERSION"

cd "$SRC_DIR/kilocode"

log "Building kilo-cli $VERSION ..."
npm install
npm run build

log "Linking kilo globally ..."
sudo npm link

log "kilo-cli $VERSION installed successfully."

cleanup_source kilocode
