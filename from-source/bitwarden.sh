#!/usr/bin/env bash
# Bitwarden Desktop is a TypeScript/Electron app.
# Electron apps are complex to build from source. If the build fails,
# this script will fall back to installing via Flatpak.
set -euo pipefail

VERSION=desktop-v2025.1.3

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed bitwarden; then
  log "Bitwarden is already installed, skipping."
  exit 0
fi

require_cmd node
require_cmd npm

clone_or_pull https://github.com/bitwarden/clients.git bitwarden "$VERSION"

cd "$SRC_DIR/bitwarden/apps/desktop"

log "Building Bitwarden Desktop $VERSION ..."

if npm ci && npm run build && npm run dist:dir; then
  log "Bitwarden Desktop $VERSION built successfully."
  log "The built application is in $SRC_DIR/bitwarden/apps/desktop/dist/"
else
  warn "From-source build failed. Falling back to Flatpak installation."
  flatpak_install_if_missing com.bitwarden.desktop || {
    err "Flatpak fallback also failed. Please install Bitwarden Desktop manually."
    exit 1
  }
  log "Bitwarden Desktop installed via Flatpak fallback."
fi

cleanup_source bitwarden
