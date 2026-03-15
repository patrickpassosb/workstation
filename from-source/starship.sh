#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.22.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/starship/starship.git starship "$VERSION"

log "starship $VERSION cloned to $SRC_DIR/starship"
log "To build manually (requires Rust/cargo):"
log "  cd $SRC_DIR/starship"
log "  cargo build --release"
log "  sudo install -m 0755 target/release/starship $INSTALL_PREFIX/bin/starship"
