#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed starship; then
  log "starship is already installed: $(starship --version)"
else
  log "Installing starship via official installer (latest)..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
