#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed brew; then
  log "Homebrew is already installed: $(brew --version | head -1)"
  exit 0
fi

# Homebrew refuses to run as root
if [[ "$(id -u)" -eq 0 ]]; then
  warn "Homebrew cannot be installed as root. Run setup.sh without sudo, or install Homebrew manually."
  exit 0
fi

log "Installing Homebrew..."
# Pin to a specific Homebrew/install ref instead of HEAD. Set
# HOMEBREW_INSTALLER_SHA256 to verify the install script. Without it,
# the script is still downloaded-then-executed (not piped to bash).
# NONINTERACTIVE=1 is honored by Homebrew's install.sh via env var.
export NONINTERACTIVE=1
HOMEBREW_TAG="${HOMEBREW_TAG:-master}"
if ! run_installer_script \
  "https://raw.githubusercontent.com/Homebrew/install/${HOMEBREW_TAG}/install.sh" \
  "${HOMEBREW_INSTALLER_SHA256:-}"; then
  err "Homebrew install failed"
  exit 1
fi

# Add brew to PATH for this session (Linux default location)
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

log "Homebrew installed: $(brew --version | head -1)"
