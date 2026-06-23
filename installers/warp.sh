#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed warp-terminal; then
  log "Warp terminal is already installed."
  exit 0
fi

case "$(uname -m)" in
  x86_64)  arch=""        ;;  # default (no suffix)
  aarch64) arch="_arm64"  ;;
  *)
    err "Unsupported architecture for Warp: $(uname -m)"
    exit 1
    ;;
esac

if is_fedora_like; then
  pkg="rpm${arch}"
else
  pkg="deb${arch}"
fi

url="https://app.warp.dev/get_warp?package=${pkg}"
tmp="$(mktemp --suffix=".${pkg:0:3}")"
trap 'rm -f "$tmp"' EXIT

log "Downloading Warp (.${pkg}) from $url"
curl -fL "$url" -o "$tmp" || {
  err "Warp download failed"
  exit 1
}

log "Installing Warp..."
if is_fedora_like; then
  sudo dnf install -y "$tmp"
else
  sudo apt-get install -y "$tmp"
fi

log "Warp terminal installed."
