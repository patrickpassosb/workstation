#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed antigravity; then
  log "Antigravity CLI is already installed."
  exit 0
fi

log "Installing Antigravity CLI..."
# Set ANTIGRAVITY_INSTALLER_SHA256 to verify the install script. Without
# it, the script is still downloaded-then-executed (not piped to bash).
if ! run_installer_script \
  "https://antigravity.google/cli/install.sh" \
  "${ANTIGRAVITY_INSTALLER_SHA256:-}"; then
  err "Antigravity CLI install failed"
  exit 1
fi

if is_installed antigravity; then
  log "Antigravity CLI installed."
else
  warn "Antigravity CLI installer ran, but 'antigravity' is not on PATH yet."
  warn "You may need to restart your shell or source the installer's env file."
fi
