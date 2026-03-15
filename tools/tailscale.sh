#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.82.5
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed tailscale; then
      log "tailscale is already installed: $(tailscale version | head -1)"
    else
      log "Installing tailscale via official installer..."
      curl -fsSL https://tailscale.com/install.sh | sh
    fi
    ;;
  clone)
    clone_or_pull https://github.com/tailscale/tailscale.git tailscale "$VERSION"
    log "tailscale $VERSION cloned to $SRC_DIR/tailscale"
    log "To build manually (requires Go):"
    log "  cd $SRC_DIR/tailscale"
    log "  go build -o tailscale ./cmd/tailscale"
    log "  go build -o tailscaled ./cmd/tailscaled"
    log "  sudo install -m 0755 tailscale $INSTALL_PREFIX/bin/tailscale"
    log "  sudo install -m 0755 tailscaled $INSTALL_PREFIX/sbin/tailscaled"
    ;;
  build)
    clone_or_pull https://github.com/tailscale/tailscale.git tailscale "$VERSION"
    require_cmd go
    log "Building tailscale $VERSION..."
    cd "$SRC_DIR/tailscale"
    go build -o tailscale ./cmd/tailscale
    go build -o tailscaled ./cmd/tailscaled
    sudo install -m 0755 tailscale "$INSTALL_PREFIX/bin/tailscale"
    sudo install -m 0755 tailscaled "$INSTALL_PREFIX/sbin/tailscaled"
    log "tailscale installed to $INSTALL_PREFIX/bin/tailscale"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
