#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.21.3
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed eza; then
  log "eza is already installed: $(eza --version | head -1)"
else
  # Try apt first (available on Ubuntu 24.04+)
  if apt-cache show eza > /dev/null 2>&1; then
    apt_install_if_missing eza
  else
    # Fall back to GitHub release
    log "eza not in apt repos — installing from GitHub release..."
    local tag
    tag="$(github_latest_tag 'eza-community/eza')"
    local version="${tag#v}"
    local asset="eza_x86_64-unknown-linux-gnu.tar.gz"
    github_release_install "eza-community/eza" "$tag" "$asset" "eza"
  fi
fi
