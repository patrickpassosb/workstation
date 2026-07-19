#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed tailscale; then
  log "tailscale is already installed: $(tailscale version | head -1)"
else
  log "Installing tailscale via official installer..."
  # Set TAILSCALE_INSTALLER_SHA256 to verify the install script. Without
  # it, the script is still downloaded-then-executed (not piped to sh).
  run_installer_script \
    "https://tailscale.com/install.sh" \
    "${TAILSCALE_INSTALLER_SHA256:-}"
fi
