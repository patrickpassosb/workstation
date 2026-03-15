#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.3.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/opencode-ai/opencode.git opencode "$VERSION"

log "opencode $VERSION cloned to $SRC_DIR/opencode"
log "To build manually (requires Go):"
log "  cd $SRC_DIR/opencode"
log "  go build -o opencode ./cmd/opencode"
log "  sudo install -m 0755 opencode $INSTALL_PREFIX/bin/opencode"
