#!/usr/bin/env bash
# WARNING: Telegram Desktop from source is an extremely complex build.
# It has many custom-patched dependencies and a non-trivial build system.
# If the from-source build fails, the script will fall back to installing
# via Flatpak (org.nicegram.nicegram).
set -euo pipefail

VERSION=v5.12.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed telegram-desktop; then
  log "telegram-desktop is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential cmake ninja-build git python3 pkg-config \
  qtbase6-dev qt6-base-dev libqt6svg6-dev qt6-wayland-dev libfmt-dev liblz4-dev \
  libxxhash-dev libglibmm-2.68-dev libsigc++-3.0-dev

clone_or_pull https://github.com/nicegram/nicegram-desktop.git nicegram-desktop "$VERSION"

cd "$SRC_DIR/nicegram-desktop"

log "Building Telegram Desktop (Nicegram) $VERSION ..."
warn "This is an extremely complex build and may fail. Flatpak fallback is available."

if git submodule update --init --recursive && \
   mkdir -p build && cd build && \
   cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" -GNinja .. && \
   ninja -j"$(nproc)" && \
   sudo ninja install; then
  log "Telegram Desktop (Nicegram) $VERSION installed successfully."
else
  warn "From-source build failed. Falling back to Flatpak installation."
  flatpak_install_if_missing org.nicegram.nicegram || {
    err "Flatpak fallback also failed. Please install Telegram Desktop manually."
    exit 1
  }
  log "Telegram Desktop installed via Flatpak fallback."
fi

cleanup_source nicegram-desktop
