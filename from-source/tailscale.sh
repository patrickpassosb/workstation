#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.82.5

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/tailscale/tailscale.git tailscale "$VERSION"

log "tailscale $VERSION cloned to $SRC_DIR/tailscale"
log "To build manually (requires Go):"
log "  cd $SRC_DIR/tailscale"
log "  go build -o tailscale ./cmd/tailscale"
log "  go build -o tailscaled ./cmd/tailscaled"
log "  sudo install -m 0755 tailscale $INSTALL_PREFIX/bin/tailscale"
log "  sudo install -m 0755 tailscaled $INSTALL_PREFIX/sbin/tailscaled"
