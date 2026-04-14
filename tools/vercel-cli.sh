#!/usr/bin/env bash
set -euo pipefail

VERSION=vercel@41.5.0
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

ensure_node
log "Installing vercel-cli..."
bun_or_npm_install_global vercel
