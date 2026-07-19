#!/usr/bin/env bash
set -euo pipefail

VERSION=0.18.2
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed delta; then
  log "delta is already installed: $(delta --version)"
else
  # Delta's deb/tarball release asset names are arch-specific.
  case "$(uname -m)" in
    x86_64|amd64)   delta_deb_arch="amd64";         delta_tar_arch="x86_64-unknown-linux-musl" ;;
    aarch64|arm64)  delta_deb_arch="arm64";         delta_tar_arch="aarch64-unknown-linux-musl" ;;
    *)
      warn "delta has no prebuilt binary for $(uname -m); skipping."
      exit 0
      ;;
  esac
  if pkg_available git-delta; then
    pkg_install_if_missing git-delta
  elif is_ubuntu_like; then
    log "Installing delta from GitHub .deb release..."
    tag="$VERSION"
    asset="git-delta_${VERSION}_${delta_deb_arch}.deb"
    url="https://github.com/dandavison/delta/releases/download/${tag}/${asset}"
    tmp_deb="$(mktemp --suffix=.deb)"
    trap 'rm -f "$tmp_deb"' RETURN
    safe_curl -o "$tmp_deb" "$url"
    sudo dpkg -i "$tmp_deb"
  else
    log "Installing delta from GitHub tarball release..."
    github_release_install "dandavison/delta" "$VERSION" \
      "delta-${VERSION}-${delta_tar_arch}.tar.gz" "delta"
  fi
  log "delta installed: $(delta --version)"
fi
