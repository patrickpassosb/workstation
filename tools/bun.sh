#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed bun; then
  log "bun is already installed: $(bun --version)"
else
  log "Installing bun via official installer..."
  # Set BUN_VERSION to install a specific release (the upstream
  # installer reads $BUN_VERSION from the env). Set BUN_INSTALLER_SHA256
  # to verify the install script. Without a SHA256 the script is still
  # downloaded-then-executed (no longer piped straight to bash).
  if [[ -n "${BUN_VERSION:-}" ]]; then
    BUN_VERSION="$BUN_VERSION" run_installer_script \
      "https://raw.githubusercontent.com/oven-sh/bun-install/main/install.sh" \
      "${BUN_INSTALLER_SHA256:-}"
  else
    run_installer_script \
      "https://raw.githubusercontent.com/oven-sh/bun-install/main/install.sh" \
      "${BUN_INSTALLER_SHA256:-}"
  fi
  # Source bun env so it's available in the current session
  if [[ -f "$HOME/.bun/bin/bun" ]]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    log "bun installed: $(bun --version)"
  fi
fi
