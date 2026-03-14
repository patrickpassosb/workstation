#!/usr/bin/env bash
# Requires: go (install via snap install go --classic or from https://go.dev/dl/)
set -euo pipefail

VERSION=v0.24.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed lazydocker && [[ "$(lazydocker --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "lazydocker $VERSION is already installed, skipping."
  exit 0
fi

require_cmd go

clone_or_pull https://github.com/jesseduffield/lazydocker.git lazydocker "$VERSION"

cd "$SRC_DIR/lazydocker"

log "Building lazydocker $VERSION ..."
go build -o lazydocker .

sudo install -m 0755 lazydocker "$INSTALL_PREFIX/bin/lazydocker"

log "lazydocker $VERSION installed successfully."

cleanup_source lazydocker
