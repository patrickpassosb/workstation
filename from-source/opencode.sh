#!/usr/bin/env bash
# Requires: go (install via snap install go --classic or from https://go.dev/dl/)
set -euo pipefail

VERSION=v0.3.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed opencode && [[ "$(opencode --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "opencode $VERSION is already installed, skipping."
  exit 0
fi

require_cmd go

clone_or_pull https://github.com/opencode-ai/opencode.git opencode "$VERSION"

cd "$SRC_DIR/opencode"

log "Building opencode $VERSION ..."
go build -o opencode ./cmd/opencode

sudo install -m 0755 opencode "$INSTALL_PREFIX/bin/opencode"

log "opencode $VERSION installed successfully."

cleanup_source opencode
