#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.3.4
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

ensure_node
log "Installing gemini-cli..."
bun_or_npm_install_global @google/gemini-cli
