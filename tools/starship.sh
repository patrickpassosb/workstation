#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.22.1
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed starship; then
  log "starship is already installed: $(starship --version)"
else
  log "Installing starship via official installer..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
