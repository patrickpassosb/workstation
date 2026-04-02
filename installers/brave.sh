#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed brave-browser; then
  log "Brave browser is already installed."
  exit 0
fi

log "Installing Brave browser..."

# Download GPG key to the location Brave's own package expects
sudo install -d -m 0755 /usr/share/keyrings
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
  "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"

# Use DEB822 .sources format (matches Brave's official config)
sudo tee /etc/apt/sources.list.d/brave-browser-release.sources >/dev/null <<EOF
Types: deb
URIs: https://brave-browser-apt-release.s3.brave.com
Suites: stable
Components: main
Architectures: amd64 arm64
Signed-By: /usr/share/keyrings/brave-browser-archive-keyring.gpg
EOF

# Remove old .list format if it exists (avoids duplicate source errors)
sudo rm -f /etc/apt/sources.list.d/brave-browser.list

sudo apt-get update -y
sudo apt-get install -y brave-browser

log "Brave browser installed."
