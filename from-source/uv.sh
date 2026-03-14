#!/usr/bin/env bash
set -euo pipefail

VERSION=0.7.2

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed uv && [[ "$(uv --version)" == *"$VERSION"* ]]; then
  log "uv $VERSION is already installed, skipping."
  exit 0
fi

require_cmd cargo

clone_or_pull https://github.com/astral-sh/uv.git uv "$VERSION"

cd "$SRC_DIR/uv"

log "Building uv $VERSION ..."
cargo build --release

sudo install -m 0755 target/release/uv "$INSTALL_PREFIX/bin/uv"

if [[ -f target/release/uvx ]]; then
  sudo install -m 0755 target/release/uvx "$INSTALL_PREFIX/bin/uvx"
  log "uv and uvx $VERSION installed successfully."
else
  log "uv $VERSION installed successfully."
fi

cleanup_source uv
