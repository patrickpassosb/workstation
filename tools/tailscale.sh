#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.82.5
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed tailscale; then
  log "tailscale is already installed: $(tailscale version | head -1)"
else
  log "Installing tailscale via official installer..."
  curl -fsSL https://tailscale.com/install.sh | sh
fi
