#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed google-chrome || is_installed google-chrome-stable; then
  log "Google Chrome is already installed."
  exit 0
fi

log "Installing Google Chrome..."

# Add GPG key (needs dearmoring from ASCII-armored format)
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
  | sudo gpg --dearmor --yes -o /etc/apt/keyrings/google-chrome-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/google-chrome-keyring.gpg arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
  | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y google-chrome-stable

log "Google Chrome installed."
