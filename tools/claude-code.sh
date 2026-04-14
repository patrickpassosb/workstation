#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.0.20
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

ensure_node
log "Installing claude-code..."
bun_or_npm_install_global @anthropic-ai/claude-code
