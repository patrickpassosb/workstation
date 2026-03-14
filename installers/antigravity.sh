#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed antigravity || dpkg -s antigravity >/dev/null 2>&1; then
  log "Antigravity IDE is already installed."
  exit 0
fi

log "Installing Antigravity IDE..."

# Try APT first
if apt_install_if_missing antigravity; then
  log "Antigravity IDE installed via APT."
  exit 0
fi

# Fallback: check for a .deb URL in the environment
if [[ -n "${ANTIGRAVITY_DEB_URL:-}" ]]; then
  log "Downloading Antigravity .deb from $ANTIGRAVITY_DEB_URL"
  curl -fL "$ANTIGRAVITY_DEB_URL" -o /tmp/antigravity.deb
  sudo apt-get install -y /tmp/antigravity.deb
  rm -f /tmp/antigravity.deb
  log "Antigravity IDE installed from .deb."
  exit 0
fi

# Neither method available
warn "Antigravity IDE is not available in APT and ANTIGRAVITY_DEB_URL is not set."
warn "Please download it manually from: https://www.antigravityide.app/download"
exit 1
