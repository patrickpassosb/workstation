#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.1.0
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

ensure_node
log "Installing context-hub..."
bun_or_npm_install_global @aisuite/chub
