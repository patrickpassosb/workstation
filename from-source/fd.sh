#!/usr/bin/env bash
set -euo pipefail

VERSION=v10.2.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/sharkdp/fd.git fd "$VERSION"

log "fd $VERSION cloned to $SRC_DIR/fd"
log "To build manually (requires Rust/cargo):"
log "  cd $SRC_DIR/fd"
log "  cargo build --release"
log "  sudo install -m 0755 target/release/fd $INSTALL_PREFIX/bin/fd"
