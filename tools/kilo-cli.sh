#!/usr/bin/env bash
set -euo pipefail

VERSION=v3.16.5
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

ensure_node
log "Installing kilo-cli..."
bun_or_npm_install_global kilocode
