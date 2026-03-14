#!/usr/bin/env bash
# Requires: go (install via snap install go --classic or from https://go.dev/dl/)
set -euo pipefail

VERSION=v1.82.5

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed tailscale && [[ "$(tailscale version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "tailscale $VERSION is already installed, skipping."
  exit 0
fi

require_cmd go

clone_or_pull https://github.com/tailscale/tailscale.git tailscale "$VERSION"

cd "$SRC_DIR/tailscale"

log "Building tailscale $VERSION ..."
go build -o tailscale ./cmd/tailscale
go build -o tailscaled ./cmd/tailscaled

sudo install -m 0755 tailscale "$INSTALL_PREFIX/bin/tailscale"
sudo install -d -m 0755 "$INSTALL_PREFIX/sbin"
sudo install -m 0755 tailscaled "$INSTALL_PREFIX/sbin/tailscaled"

log "tailscale $VERSION installed successfully."

cleanup_source tailscale
