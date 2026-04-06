#!/usr/bin/env bash
# Install Voquill using the official apt-based method

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed voquill; then
    log "Voquill is already installed."
    exit 0
fi

log "Installing Voquill (voquill.github.io method)..."
curl -fsSL https://voquill.github.io/apt/install.sh | sudo bash || warn "Voquill installation failed"

if is_installed voquill; then
    log "Voquill installed successfully."
else
    warn "Voquill binary not found after installation script."
fi
