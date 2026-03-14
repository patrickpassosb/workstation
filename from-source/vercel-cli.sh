#!/usr/bin/env bash
# Build Vercel CLI from source
# Requires: node, npm
set -euo pipefail

VERSION=vercel@41.5.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed vercel && [[ "$(vercel --version 2>&1)" == *"41.5.0"* ]]; then
  log "vercel-cli $VERSION is already installed, skipping."
  exit 0
fi

require_cmd node
require_cmd npm

clone_or_pull https://github.com/vercel/vercel.git vercel "$VERSION"

cd "$SRC_DIR/vercel"

log "Building vercel-cli $VERSION ..."
npm install
npx turbo run build --filter=vercel

log "Linking vercel globally ..."
cd packages/cli
sudo npm link

log "vercel-cli $VERSION installed successfully."

cleanup_source vercel
