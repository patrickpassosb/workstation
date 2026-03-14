#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed brave-browser; then
  log "Brave browser is already installed."
  exit 0
fi

log "Installing Brave browser..."

add_apt_repo "brave-browser" \
  "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
  "deb [signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"

sudo apt-get install -y brave-browser

log "Brave browser installed."
