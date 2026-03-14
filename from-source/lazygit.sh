#!/usr/bin/env bash
# Requires: go (install via snap install go --classic or from https://go.dev/dl/)
set -euo pipefail

VERSION=v0.50.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed lazygit && [[ "$(lazygit --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "lazygit $VERSION is already installed, skipping."
  exit 0
fi

require_cmd go

clone_or_pull https://github.com/jesseduffield/lazygit.git lazygit "$VERSION"

cd "$SRC_DIR/lazygit"

log "Building lazygit $VERSION ..."
go build -o lazygit .

sudo install -m 0755 lazygit "$INSTALL_PREFIX/bin/lazygit"

log "lazygit $VERSION installed successfully."

cleanup_source lazygit
