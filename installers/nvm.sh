#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if [ -d "$HOME/.nvm" ]; then
  log "NVM is already installed at $HOME/.nvm"
  exit 0
fi

log "Installing NVM..."
git clone https://github.com/nvm-sh/nvm.git "$HOME/.nvm"

# Checkout the latest tag
cd "$HOME/.nvm"
LATEST_TAG="$(git describe --abbrev=0 --tags)"
log "Checking out latest NVM release: $LATEST_TAG"
git checkout "$LATEST_TAG"

# Source nvm so it is available in this session
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
source "$NVM_DIR/nvm.sh"

log "NVM installed: $(nvm --version)"

# Install latest LTS so node/npm are available immediately
log "Installing Node.js LTS..."
nvm install --lts
nvm alias default lts/*
log "Node.js $(node --version) installed as default"
