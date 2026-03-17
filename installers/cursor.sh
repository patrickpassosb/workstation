#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed cursor || dpkg -s cursor >/dev/null 2>&1; then
  log "Cursor is already installed."
  exit 0
fi

log "Installing Cursor editor..."

# Download .deb (includes apt repo + signing key for auto-updates)
DEB_URL="https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.6"
TMP_DEB="/tmp/cursor.deb"

curl -fL "$DEB_URL" -o "$TMP_DEB"
sudo apt-get install -y "$TMP_DEB"
rm -f "$TMP_DEB"

log "Cursor installed (apt repo configured for auto-updates)"
