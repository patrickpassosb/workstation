#!/usr/bin/env bash
set -euo pipefail

VERSION=14.1.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/BurntSushi/ripgrep.git ripgrep "$VERSION"

log "ripgrep $VERSION cloned to $SRC_DIR/ripgrep"
log "To build manually (requires Rust/cargo):"
log "  cd $SRC_DIR/ripgrep"
log "  cargo build --release"
log "  sudo install -m 0755 target/release/rg $INSTALL_PREFIX/bin/rg"
