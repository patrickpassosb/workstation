#!/usr/bin/env bash
set -euo pipefail

VERSION=14.1.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed rg && [[ "$(rg --version)" == *"$VERSION"* ]]; then
  log "ripgrep $VERSION is already installed, skipping."
  exit 0
fi

require_cmd cargo

clone_or_pull https://github.com/BurntSushi/ripgrep.git ripgrep "$VERSION"

cd "$SRC_DIR/ripgrep"

log "Building ripgrep $VERSION ..."
cargo build --release

sudo install -m 0755 target/release/rg "$INSTALL_PREFIX/bin/rg"

log "ripgrep $VERSION installed successfully."

cleanup_source ripgrep
