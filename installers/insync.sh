#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed insync; then
  log "InSync is already installed."
  exit 0
fi

log "Installing InSync..."

# Determine the Ubuntu codename for the repo
CODENAME="$(lsb_release -cs 2>/dev/null || echo "jammy")"

# Add GPG key (ASCII-armored, needs dearmoring)
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL "https://d2t3ff60b2tber.cloudfront.net/services@insynchq.com.gpg.key" \
  | sudo gpg --dearmor -o /etc/apt/keyrings/insync-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/insync-archive-keyring.gpg] http://apt.insync.io/ubuntu ${CODENAME} non-free contrib" \
  | sudo tee /etc/apt/sources.list.d/insync.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y insync

log "InSync installed."
