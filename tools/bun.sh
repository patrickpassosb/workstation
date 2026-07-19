#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed bun; then
  log "bun is already installed: $(bun --version)"
else
  log "Installing bun via official installer (latest)..."
  # Bun publishes per-release installers. Pin BUN_VERSION to a specific
  # release and BUN_INSTALLER_SHA256 to the SHA256 of the install script
  # at that tag for verified installs. Without a SHA256 the script is
  # still downloaded-then-executed (no longer piped straight to bash).
  run_installer_script \
    "https://raw.githubusercontent.com/oven-sh/bun-install/main/install.sh" \
    "${BUN_INSTALLER_SHA256:-}"
  # Source bun env so it's available in the current session
  if [[ -f "$HOME/.bun/bin/bun" ]]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    log "bun installed: $(bun --version)"
  fi
fi
