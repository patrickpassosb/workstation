#!/usr/bin/env bash
set -euo pipefail

VERSION=0.7.2

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/astral-sh/uv.git uv "$VERSION"

log "uv $VERSION cloned to $SRC_DIR/uv"
log "To build manually (requires Rust/cargo):"
log "  cd $SRC_DIR/uv"
log "  cargo build --release"
log "  sudo install -m 0755 target/release/uv $INSTALL_PREFIX/bin/uv"
log "  sudo install -m 0755 target/release/uvx $INSTALL_PREFIX/bin/uvx  # if uvx exists"
