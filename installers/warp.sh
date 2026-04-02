#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed warp-terminal; then
  log "Warp terminal is already installed."
  exit 0
fi

log "Installing Warp terminal..."

# Warp's key is ASCII-armored (.asc) and needs dearmoring
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://releases.warp.dev/linux/keys/warp.asc \
  | sudo gpg --dearmor --yes -o /etc/apt/keyrings/warpdotdev.gpg

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/warpdotdev.list >/dev/null

# Remove old source file if it exists
sudo rm -f /etc/apt/sources.list.d/warp.list

sudo apt-get update -y
sudo apt-get install -y warp-terminal

log "Warp terminal installed."
