#!/usr/bin/env bash
set -euo pipefail

VERSION=v22.15.0
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed node; then
  log "Node.js is already installed: $(node --version)"
else
  ensure_nvm
  log "Installing Node.js LTS via nvm..."
  nvm install --lts
  log "Node.js installed: $(node --version)"
fi
