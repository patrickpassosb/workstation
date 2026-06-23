#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed antigravity; then
  log "Antigravity CLI is already installed."
  exit 0
fi

log "Installing Antigravity CLI (curl|bash)..."
if ! curl -fsSL https://antigravity.google/cli/install.sh | bash; then
  err "Antigravity CLI install failed"
  exit 1
fi

if is_installed antigravity; then
  log "Antigravity CLI installed."
else
  warn "Antigravity CLI installer ran, but 'antigravity' is not on PATH yet."
  warn "You may need to restart your shell or source the installer's env file."
fi
