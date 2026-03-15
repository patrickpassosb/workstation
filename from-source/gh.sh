#!/usr/bin/env bash
set -euo pipefail

VERSION=v2.69.0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/cli/cli.git gh "$VERSION"

log "gh $VERSION cloned to $SRC_DIR/gh"
log "To build manually (requires Go):"
log "  cd $SRC_DIR/gh"
log "  make bin/gh"
log "  sudo install -m 0755 bin/gh $INSTALL_PREFIX/bin/gh"
