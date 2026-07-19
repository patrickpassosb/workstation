#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed uv; then
  log "uv is already installed: $(uv --version)"
else
  log "Installing uv via official installer (latest)..."
  # Set UV_INSTALLER_SHA256 to verify the install script. Without it,
  # the script is still downloaded-then-executed (not piped to sh).
  run_installer_script \
    "https://astral.sh/uv/install.sh" \
    "${UV_INSTALLER_SHA256:-}"
fi
