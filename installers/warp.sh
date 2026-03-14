#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed warp-terminal; then
  log "Warp terminal is already installed."
  exit 0
fi

log "Installing Warp terminal..."

add_apt_repo "warp" \
  "https://releases.warp.dev/linux/keys/warp.gpg" \
  "deb [signed-by=/etc/apt/keyrings/warp-archive-keyring.gpg arch=amd64] https://releases.warp.dev/linux/deb stable main"

sudo apt-get install -y warp-terminal

log "Warp terminal installed."
