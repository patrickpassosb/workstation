#!/usr/bin/env bash
set -euo pipefail

VERSION=bun-v1.2.9
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed bun; then
  log "bun is already installed: $(bun --version)"
else
  log "Installing bun via official installer..."
  curl -fsSL https://bun.sh/install | bash
  # Source bun env so it's available in the current session
  if [[ -f "$HOME/.bun/bin/bun" ]]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    log "bun installed: $(bun --version)"
  fi
fi
