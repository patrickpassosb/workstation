#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed starship; then
  log "starship is already installed: $(starship --version)"
else
  log "Installing starship via official installer (latest)..."
  # Set STARSHIP_INSTALLER_SHA256 to verify the install script. Without
  # it, the script is still downloaded-then-executed (not piped to sh).
  run_installer_script \
    "https://starship.rs/install.sh" \
    "${STARSHIP_INSTALLER_SHA256:-}" \
    --yes
fi
