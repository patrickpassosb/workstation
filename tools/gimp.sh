#!/usr/bin/env bash
set -euo pipefail

VERSION=GIMP_2_10_38
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    flatpak_install_if_missing org.gimp.GIMP
    ;;
  clone)
    clone_or_pull https://gitlab.gnome.org/GNOME/gimp.git gimp "$VERSION"
    log "GIMP $VERSION cloned to $SRC_DIR/gimp"
    log "WARNING: GIMP from source has many dependencies and may require additional system libraries."
    log "To build manually:"
    log "  sudo apt install build-essential meson ninja-build git pkg-config libgtk-3-dev \\"
    log "    libgegl-dev libgexiv2-dev libgirepository1.0-dev libpoppler-glib-dev libtiff-dev \\"
    log "    libjpeg-dev libpng-dev librsvg2-dev libmypaint-dev mypaint-brushes libwebp-dev \\"
    log "    libheif-dev libopenjp2-7-dev liblcms2-dev libmng-dev libwmf-dev libaa1-dev \\"
    log "    intltool iso-codes xsltproc"
    log "  cd $SRC_DIR/gimp"
    log "  meson setup _build --prefix=$INSTALL_PREFIX"
    log "  ninja -C _build"
    log "  sudo ninja -C _build install"
    ;;
  build)
    clone_or_pull https://gitlab.gnome.org/GNOME/gimp.git gimp "$VERSION"
    ensure_build_deps build-essential meson ninja-build pkg-config libgtk-3-dev \
      libgegl-dev libgexiv2-dev libgirepository1.0-dev libpoppler-glib-dev libtiff-dev \
      libjpeg-dev libpng-dev librsvg2-dev libmypaint-dev mypaint-brushes libwebp-dev \
      libheif-dev libopenjp2-7-dev liblcms2-dev libmng-dev libwmf-dev libaa1-dev \
      intltool iso-codes xsltproc
    log "Building GIMP $VERSION (this may take a while)..."
    cd "$SRC_DIR/gimp"
    meson setup _build --prefix="$INSTALL_PREFIX"
    ninja -C _build
    sudo ninja -C _build install
    log "GIMP installed"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
