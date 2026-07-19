#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed zoom; then
  log "Zoom is already installed."
  exit 0
fi

if is_fedora_like; then
  if command -v flatpak >/dev/null 2>&1 && flatpak info us.zoom.Zoom >/dev/null 2>&1; then
    log "Zoom is already installed via Flatpak."
    exit 0
  fi
  log "Installing Zoom via Flatpak..."
  flatpak_install_if_missing us.zoom.Zoom
  log "Zoom installed."
  exit 0
fi

log "Installing Zoom..."

# Zoom's deb endpoint uses "latest" with no checksum published, so we
# can't pin a SHA256 here. At minimum use mktemp (not a predictable
# /tmp/zoom_amd64.deb path that's vulnerable to TOCTOU before sudo),
# dispatch on arch, and use safe_curl's retry/timeout flags.
case "$(uname -m)" in
  x86_64|amd64) zoom_arch="amd64" ;;
  aarch64|arm64) zoom_arch="arm64" ;;
  *)
    warn "Zoom does not publish a deb for $(uname -m); skipping."
    exit 0
    ;;
esac

tmp_deb="$(mktemp --suffix=".deb")"
trap 'rm -f "$tmp_deb"' RETURN

# Use safe_curl (--fail --retry --max-time) instead of bare curl -fL.
if ! safe_curl -o "$tmp_deb" "https://zoom.us/client/latest/zoom_${zoom_arch}.deb"; then
  err "Zoom deb download failed"
  exit 1
fi

log "  downloaded SHA256: $(sha256sum "$tmp_deb" | cut -d' ' -f1)"
log "  (Zoom does not publish a checksum for this endpoint — verify manually if needed)"

sudo apt-get install -y "$tmp_deb"

log "Zoom installed."
