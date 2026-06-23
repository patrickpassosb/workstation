#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

APP_DIR="${OBSIDIAN_APP_DIR:-$HOME/AppImage}"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$DESKTOP_DIR/obsidian-appimage.desktop"

ensure_local_bin_dir
mkdir -p "$APP_DIR" "$DESKTOP_DIR"

case "$(uname -m)" in
  x86_64)  asset_suffix=".AppImage" ;;
  aarch64) asset_suffix="-arm64.AppImage" ;;
  *)       err "Unsupported architecture for Obsidian AppImage: $(uname -m)"; exit 1 ;;
esac

existing_appimage="$(
  find "$APP_DIR" -maxdepth 1 -name 'Obsidian-*.AppImage' -type f -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | head -n 1 \
    | cut -d' ' -f2-
)"

version="${OBSIDIAN_VERSION:-$(github_latest_tag obsidianmd/obsidian-releases 2>/dev/null || true)}"
appimage=""

if [[ -n "$version" ]]; then
  local_version="${version#v}"
  asset="Obsidian-${local_version}${asset_suffix}"
  appimage="$APP_DIR/$asset"
  if [[ ! -f "$appimage" ]]; then
    log "Downloading Obsidian ${version} AppImage..."
    curl -fL "https://github.com/obsidianmd/obsidian-releases/releases/download/${version}/${asset}" \
      -o "$appimage"
  else
    log "Obsidian AppImage already present: $appimage"
  fi
elif [[ -n "$existing_appimage" ]]; then
  appimage="$existing_appimage"
  warn "Could not resolve latest Obsidian release; using existing AppImage: $appimage"
else
  err "Could not resolve latest Obsidian release and no local AppImage was found"
  exit 1
fi

chmod +x "$appimage"
ln -sf "$appimage" "$BIN_DIR/obsidian-app"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Obsidian
Exec=$appimage %u
Terminal=false
Type=Application
Icon=obsidian
StartupWMClass=obsidian
Comment=Knowledge base
MimeType=x-scheme-handler/obsidian;
Categories=Office;Utility;
EOF

xdg-mime default "$(basename "$DESKTOP_FILE")" x-scheme-handler/obsidian 2>/dev/null \
  || warn "Could not register obsidian:// URI handler"
command -v update-desktop-database >/dev/null 2>&1 \
  && update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

if is_installed obsidian; then
  log "Obsidian CLI is available: $(command -v obsidian)"
else
  warn "Obsidian CLI binary is not registered yet. Open Obsidian once and enable CLI in Settings -> General."
fi

log "Obsidian AppImage installed at $appimage"
log "Obsidian app launcher linked as $BIN_DIR/obsidian-app"
