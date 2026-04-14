#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.25.0
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed bat || is_installed batcat; then
  log "bat is already installed"
else
  apt_install_if_missing bat
  # On Debian/Ubuntu the binary is named 'batcat' due to name conflict.
  # Create a symlink so 'bat' works everywhere.
  if is_installed batcat && ! is_installed bat; then
    sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
    log "Created symlink: bat → batcat"
  fi
fi
