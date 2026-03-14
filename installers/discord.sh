#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if flatpak info com.discordapp.Discord >/dev/null 2>&1; then
  log "Discord is already installed via Flatpak."
  exit 0
fi

log "Installing Discord via Flatpak..."
flatpak_install_if_missing com.discordapp.Discord

log "Discord installed."
