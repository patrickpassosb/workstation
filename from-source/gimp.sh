#!/usr/bin/env bash
# WARNING: GIMP from source has many dependencies and may require additional system libraries.
set -euo pipefail

VERSION=GIMP_2_10_38

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed gimp && [[ "$(gimp --version 2>&1)" == *"${VERSION//GIMP_/}"* ]]; then
  log "GIMP $VERSION is already installed, skipping."
  exit 0
fi

warn "GIMP from source has many dependencies and may require additional system libraries."

ensure_build_deps build-essential meson ninja-build git pkg-config libgtk-3-dev \
  libgegl-dev libgexiv2-dev libgirepository1.0-dev libpoppler-glib-dev libtiff-dev \
  libjpeg-dev libpng-dev librsvg2-dev libmypaint-dev mypaint-brushes libwebp-dev \
  libheif-dev libopenjp2-7-dev liblcms2-dev libmng-dev libwmf-dev libaa1-dev \
  intltool iso-codes xsltproc

clone_or_pull https://gitlab.gnome.org/GNOME/gimp.git gimp "$VERSION"

cd "$SRC_DIR/gimp"

log "Building GIMP $VERSION ..."
meson setup _build --prefix="$INSTALL_PREFIX"
ninja -C _build
sudo ninja -C _build install

log "GIMP $VERSION installed successfully."

cleanup_source gimp
