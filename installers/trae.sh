#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

# ── Skip if already installed ─────────────────────────────────────────
if is_installed trae || pkg_is_installed trae; then
  log "Trae IDE is already installed."
  exit 0
fi

# ── Resolve arch + distro + extension ─────────────────────────────────
case "$(uname -m)" in
  x86_64)  arch="x64" ;;
  aarch64) arch="arm64" ;;
  *)
    err "Unsupported architecture for Trae IDE: $(uname -m)"
    exit 1
    ;;
esac

if is_fedora_like; then
  ext="rpm"
elif is_ubuntu_like; then
  ext="deb"
else
  err "Unsupported distro for Trae IDE: $(distro_id)"
  exit 1
fi

# ── Fetch the official manifest ───────────────────────────────────────
api="https://icube-normal.trae.ai/icube/api/v1/native/version/trae/latest"
log "Fetching Trae IDE manifest from $api"
manifest="$(curl -fsSL "$api")" || {
  err "Failed to fetch Trae manifest"
  exit 1
}

# Region preference: va (US), sg (Singapore), cn (China), usttp (US Telco).
# We try va first, then fall back to any other region.
url="$(printf '%s' "$manifest" \
  | jq -r --arg arch "$arch" --arg ext "$ext" \
      '.data.manifest.linux.download[] | select(.region=="va") | .["\($arch).\($ext)"]')"

if [[ -z "$url" || "$url" == "null" ]]; then
  url="$(printf '%s' "$manifest" \
    | jq -r --arg arch "$arch" --arg ext "$ext" \
        '.data.manifest.linux.download[0] | .["\($arch).\($ext)"]')"
fi

if [[ -z "$url" || "$url" == "null" ]]; then
  err "Could not resolve Trae download URL for $arch.$ext"
  err "Manifest did not contain a matching asset."
  exit 1
fi

# ── Download + install ───────────────────────────────────────────────
tmp="$(mktemp --suffix=".$ext")"
trap 'rm -f "$tmp"' EXIT

log "Downloading Trae IDE (.${ext}, ${arch}) from $url"
curl -fL "$url" -o "$tmp" || {
  err "Trae download failed"
  exit 1
}

log "Installing Trae IDE (.${ext})..."
if is_fedora_like; then
  sudo dnf install -y "$tmp"
else
  sudo apt-get install -y "$tmp"
fi

# ── Discover the installed binary (best-effort) ──────────────────────
bin_path=""
if command -v rpm >/dev/null 2>&1; then
  bin_path="$(rpm -ql trae 2>/dev/null | grep -E '/(bin|sbin)/trae$' | head -n 1 || true)"
elif command -v dpkg >/dev/null 2>&1; then
  bin_path="$(dpkg -L trae 2>/dev/null | grep -E '/(bin|sbin)/trae$' | head -n 1 || true)"
fi

if [[ -n "$bin_path" ]]; then
  log "Trae CLI binary: $bin_path"
else
  warn "Trae CLI binary not discovered in the package; only the GUI was installed."
fi

log "Trae IDE installed."
