#!/usr/bin/env bash
set -euo pipefail

VERSION=0.18.2
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed delta; then
  log "delta is already installed: $(delta --version)"
else
  # Install from GitHub release (not in standard Ubuntu repos)
  log "Installing delta from GitHub release..."
  local tag="$VERSION"
  local asset="git-delta_${VERSION}_amd64.deb"
  local url="https://github.com/dandavison/delta/releases/download/${tag}/${asset}"
  local tmp_deb
  tmp_deb="$(mktemp --suffix=.deb)"
  curl -fSL "$url" -o "$tmp_deb"
  sudo dpkg -i "$tmp_deb"
  rm -f "$tmp_deb"
  log "delta installed: $(delta --version)"
fi
