#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.9.6
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed zoxide; then
  log "zoxide is already installed: $(zoxide --version)"
else
  if pkg_available zoxide; then
    pkg_install_if_missing zoxide
  else
    log "Installing zoxide via official installer..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
fi
