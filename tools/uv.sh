#!/usr/bin/env bash
set -euo pipefail

VERSION=0.7.2
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed uv; then
  log "uv is already installed: $(uv --version)"
else
  log "Installing uv via official installer..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
