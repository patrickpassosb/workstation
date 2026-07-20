#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed google-chrome || is_installed google-chrome-stable; then
  log "Google Chrome is already installed."
  exit 0
fi

# Chrome's apt/rpm repos only ship x86_64/amd64 packages — guard against
# arm64 hosts where the install would otherwise fail with an unhelpful
# "no package found" error.
case "$(uname -m)" in
  x86_64|amd64) : ;;
  *)
    warn "Google Chrome only publishes x86_64/amd64 packages; skipping on $(uname -m)."
    exit 0
    ;;
esac

if is_fedora_like; then
  log "Installing Google Chrome from Google's Fedora RPM repository..."
  sudo tee /etc/yum.repos.d/google-chrome.repo >/dev/null <<'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
  sudo dnf install -y google-chrome-stable
  log "Google Chrome installed."
  exit 0
fi

log "Installing Google Chrome..."

# Add GPG key (needs dearmoring from ASCII-armored format)
sudo install -d -m 0755 /etc/apt/keyrings
# Download as the user (curl reads ~/.curlrc as root — avoid), then
# install the dearmored key as root.
tmp_keyring="$(mktemp)"
trap 'rm -f "$tmp_keyring"' EXIT
safe_curl -o "$tmp_keyring" https://dl.google.com/linux/linux_signing_key.pub
sudo gpg --dearmor --yes -o /etc/apt/keyrings/google-chrome-keyring.gpg "$tmp_keyring"

# Use https:// (not http://) so the apt InRelease/Packages index is
# fetched over TLS — the GPG key alone doesn't protect the index.
echo "deb [signed-by=/etc/apt/keyrings/google-chrome-keyring.gpg arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" \
  | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y google-chrome-stable

log "Google Chrome installed."
