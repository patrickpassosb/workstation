#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

export PATH="$HOME/.local/bin:$PATH"

if is_installed semgrep; then
  log "semgrep is already installed: $(semgrep --version)"
  exit 0
fi

if ! is_installed uv; then
  warn "uv is required to install Semgrep. Run tools/uv.sh first."
  exit 1
fi

log "Installing Semgrep with uv tool (latest)..."
uv tool install semgrep
log "Semgrep installed"
