#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if [ -d "$HOME/.oh-my-zsh" ]; then
  log "Oh My Zsh is already installed at $HOME/.oh-my-zsh"
  exit 0
fi

require_cmd zsh

log "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

log "Oh My Zsh installed."
