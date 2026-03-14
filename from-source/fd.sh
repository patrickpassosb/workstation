#!/usr/bin/env bash
set -euo pipefail

VERSION=v10.2.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed fd && [[ "$(fd --version)" == *"${VERSION#v}"* ]]; then
  log "fd ${VERSION#v} is already installed, skipping."
  exit 0
fi

require_cmd cargo

clone_or_pull https://github.com/sharkdp/fd.git fd "$VERSION"

cd "$SRC_DIR/fd"

log "Building fd $VERSION ..."
cargo build --release

sudo install -m 0755 target/release/fd "$INSTALL_PREFIX/bin/fd"

log "fd ${VERSION#v} installed successfully."

cleanup_source fd
