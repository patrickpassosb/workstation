#!/usr/bin/env bash
# Requires: go (install via snap install go --classic or from https://go.dev/dl/)
set -euo pipefail

VERSION=v2.69.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed gh && [[ "$(gh --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "gh $VERSION is already installed, skipping."
  exit 0
fi

require_cmd go

clone_or_pull https://github.com/cli/cli.git gh "$VERSION"

cd "$SRC_DIR/gh"

log "Building gh $VERSION ..."
make bin/gh

sudo install -m 0755 bin/gh "$INSTALL_PREFIX/bin/gh"

log "gh $VERSION installed successfully."

cleanup_source gh
