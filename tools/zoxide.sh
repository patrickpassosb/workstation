#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed zoxide; then
  log "zoxide is already installed: $(zoxide --version)"
else
  if pkg_available zoxide; then
    pkg_install_if_missing zoxide
  else
    log "Installing zoxide via official installer..."
    # Pin to a specific release tag (NOT main) so a compromised upstream
    # commit can't silently change the install script. Set
    # ZOXIDE_INSTALLER_SHA256 to verify the bytes.
    zoxide_tag="${ZOXIDE_VERSION:-v0.9.7}"
    run_installer_script \
      "https://raw.githubusercontent.com/ajeetdsouza/zoxide/${zoxide_tag}/install.sh" \
      "${ZOXIDE_INSTALLER_SHA256:-}"
  fi
fi
