#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

# ── Skip if already installed ─────────────────────────────────────────
if is_installed voquill || pkg_is_installed voquill-desktop; then
  log "Voquill is already installed."
  exit 0
fi

# ── Resolve arch + distro + extension ─────────────────────────────────
case "$(uname -m)" in
  x86_64) ;;
  *)
    err "Voquill only ships x86_64 desktop builds (got $(uname -m))."
    exit 1
    ;;
esac

if is_fedora_like; then
  ext="rpm"
elif is_ubuntu_like; then
  ext="deb"
else
  err "Unsupported distro for Voquill: $(distro_id)"
  exit 1
fi

# ── Fetch the latest release manifest from GitHub ─────────────────────
api="https://api.github.com/repos/voquill/voquill/releases/latest"
log "Fetching Voquill release manifest from $api"
manifest="$(curl -fsSL "$api")" || {
  err "Failed to fetch Voquill manifest"
  exit 1
}

# Pick the asset URL: ends in .rpm or .deb, never aarch64.
url="$(printf '%s' "$manifest" \
  | jq -r --arg ext "$ext" \
      '.assets[] | select(.name | endswith($ext) and (contains("aarch64") | not)) | .browser_download_url' \
  | head -n 1)"

if [[ -z "$url" || "$url" == "null" ]]; then
  err "Could not find a .$ext asset for x86_64 in the latest Voquill release."
  exit 1
fi

# ── Download + install ───────────────────────────────────────────────
tmp="$(mktemp --suffix=".$ext")"
trap 'rm -f "$tmp"' EXIT

log "Downloading Voquill (.${ext}) from $url"
curl -fL "$url" -o "$tmp" || {
  err "Voquill download failed"
  exit 1
}

log "Installing Voquill (.${ext})..."
if is_fedora_like; then
  sudo dnf install -y "$tmp"
else
  sudo apt-get install -y "$tmp"
fi

# ── Discover the installed binary (best-effort) ──────────────────────
bin_path=""
if command -v rpm >/dev/null 2>&1; then
  bin_path="$(rpm -ql voquill-desktop 2>/dev/null | grep -E '/(bin|sbin)/voquill(-desktop)?$' | head -n 1 || true)"
elif command -v dpkg >/dev/null 2>&1; then
  bin_path="$(dpkg -L voquill-desktop 2>/dev/null | grep -E '/(bin|sbin)/voquill(-desktop)?$' | head -n 1 || true)"
fi

if [[ -n "$bin_path" ]]; then
  log "Voquill binary: $bin_path"
else
  warn "Voquill binary not discovered in the package; only the GUI was installed."
fi

# ── Clean up the legacy AppImage form ─────────────────────────────────
removed=0
for f in "$HOME/AppImage/voquill-desktop-"*.AppImage "$HOME/.local/bin/voquill.AppImage"; do
  if [[ -e "$f" ]]; then
    log "Removing legacy Voquill AppImage: $f"
    rm -f "$f"
    removed=1
  fi
done
[[ $removed -eq 1 ]] || true

log "Voquill installed."
