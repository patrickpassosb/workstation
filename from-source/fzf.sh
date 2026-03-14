#!/usr/bin/env bash
# Requires: go (install via snap install go --classic or from https://go.dev/dl/)
set -euo pipefail

VERSION=v0.61.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed fzf && [[ "$(fzf --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "fzf $VERSION is already installed, skipping."
  exit 0
fi

require_cmd go

clone_or_pull https://github.com/junegunn/fzf.git fzf "$VERSION"

cd "$SRC_DIR/fzf"

log "Building fzf $VERSION ..."
go build -o fzf .

sudo install -m 0755 fzf "$INSTALL_PREFIX/bin/fzf"

log "fzf $VERSION installed successfully."

cleanup_source fzf
