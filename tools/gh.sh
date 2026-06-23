#!/usr/bin/env bash
set -euo pipefail

VERSION=v2.69.0
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed gh; then
  log "gh is already installed: $(gh --version | head -1)"
elif is_fedora_like; then
  if pkg_available gh; then
    pkg_install_if_missing gh
  else
    log "Adding GitHub CLI Fedora repository..."
    add_dnf_repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh
  fi
else
  log "Adding GitHub CLI apt repository..."
  add_apt_repo "github-cli" \
    "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/github-cli-archive-keyring.gpg] https://cli.github.com/packages stable main"
  apt_install_if_missing gh
fi
