#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.1.2505302101
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

ensure_node
log "Installing codex..."
bun_or_npm_install_global @openai/codex
