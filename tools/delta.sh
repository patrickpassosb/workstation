#!/usr/bin/env bash
set -euo pipefail

VERSION=0.18.2
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed delta; then
  log "delta is already installed: $(delta --version)"
else
  if pkg_available git-delta; then
    pkg_install_if_missing git-delta
  elif is_ubuntu_like; then
    log "Installing delta from GitHub .deb release..."
    tag="$VERSION"
    asset="git-delta_${VERSION}_amd64.deb"
    url="https://github.com/dandavison/delta/releases/download/${tag}/${asset}"
    tmp_deb="$(mktemp --suffix=.deb)"
    curl -fSL "$url" -o "$tmp_deb"
    sudo dpkg -i "$tmp_deb"
    rm -f "$tmp_deb"
  else
    log "Installing delta from GitHub tarball release..."
    github_release_install "dandavison/delta" "$VERSION" \
      "delta-${VERSION}-x86_64-unknown-linux-musl.tar.gz" "delta"
  fi
  log "delta installed: $(delta --version)"
fi
