#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed zoom; then
  log "Zoom is already installed."
  exit 0
fi

log "Installing Zoom..."

curl -fL "https://zoom.us/client/latest/zoom_amd64.deb" -o /tmp/zoom_amd64.deb
sudo apt-get install -y /tmp/zoom_amd64.deb
rm -f /tmp/zoom_amd64.deb

log "Zoom installed."
