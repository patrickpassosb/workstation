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
# On Mint, lsb_release -cs returns the Mint codename (e.g. "zena"), not Ubuntu's.
CODENAME="$(get_ubuntu_codename)"

# Add GPG key
curl -fsSL "https://apt.insync.io/insynchq.gpg" \
  | gpg --dearmor --yes \
  | sudo tee /etc/apt/trusted.gpg.d/insynchq.gpg >/dev/null

echo "deb [signed-by=/etc/apt/trusted.gpg.d/insynchq.gpg] http://apt.insync.io/ubuntu ${CODENAME} non-free contrib" \
  | sudo tee /etc/apt/sources.list.d/insync.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y insync

insync start

log "InSync installed and started."
