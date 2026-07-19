#!/usr/bin/env bash
set -euo pipefail

VERSION=v10.2.0
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed fd || is_installed fdfind; then
  log "fd is already installed"
else
  # Package is 'fd' on Fedora, 'fd-find' on Ubuntu (binary is 'fdfind'
  # on Ubuntu). install_first_available_pkg tries each in turn.
  install_first_available_pkg fd fd-find
fi

if is_installed fdfind && ! is_installed fd; then
  sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  log "Created symlink: fd -> fdfind"
fi
