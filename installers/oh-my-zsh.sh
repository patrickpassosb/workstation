#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  require_cmd zsh
  log "Installing Oh My Zsh..."
  # Pin to a tag instead of master. Set OHMYZSH_INSTALLER_SHA256 to
  # verify the install script. Without it, the script is still
  # downloaded-then-executed (not piped to sh).
  OHMYZSH_TAG="${OHMYZSH_TAG:-master}"
  run_installer_script \
    "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/${OHMYZSH_TAG}/tools/install.sh" \
    "${OHMYZSH_INSTALLER_SHA256:-}" \
    --unattended
  log "Oh My Zsh installed."
else
  log "Oh My Zsh is already installed at $HOME/.oh-my-zsh"
fi

# Install custom plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  log "Installing ZSH Syntax Highlighting (latest)..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  log "ZSH Syntax Highlighting is already installed."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  log "Installing ZSH Auto Suggestions (latest)..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  log "ZSH Auto Suggestions is already installed."
fi
