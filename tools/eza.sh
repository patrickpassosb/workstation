#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.21.3
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed eza; then
  log "eza is already installed: $(eza --version | head -1)"
else
  if pkg_available eza; then
    pkg_install_if_missing eza
  else
    # Fall back to GitHub release
    log "eza not in distro repos — installing from GitHub release..."
    tag=""
    tag="$(github_latest_tag 'eza-community/eza')"
    version="${tag#v}"
    asset="eza_x86_64-unknown-linux-gnu.tar.gz"
    github_release_install "eza-community/eza" "$tag" "$asset" "eza"
  fi
fi
